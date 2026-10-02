import uuid
from django.shortcuts import render, get_object_or_404, redirect
from django.views.decorators.http import require_POST
from django.contrib.auth import login, logout, authenticate
from django.contrib.auth.forms import AuthenticationForm
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from django.core.paginator import Paginator
from django.db.models import Q
from django.db import transaction
from django.http import JsonResponse

from shop.models import Product, Tag, Order, OrderItem, Favorite
from shop.forms import SignUpForm, ProductForm, OrderCreateForm, CartAddProductForm
from shop.cart import Cart


def product_list(request):
    products = Product.objects.filter(is_active=True)
    query = request.GET.get('q', '').strip()
    tag_slug = request.GET.get('tag', '').strip()
    sort = request.GET.get('sort', 'newest')

    selected_tag = None
    if tag_slug:
        selected_tag = get_object_or_404(Tag, slug=tag_slug)
        products = products.filter(tags=selected_tag)

    if query:
        products = products.filter(
            Q(name__icontains=query) | Q(description__icontains=query)
        )

    if sort == 'price_asc':
        products = products.order_by('price')
    elif sort == 'price_desc':
        products = products.order_by('-price')
    else:
        products = products.order_by('-created_at')

    paginator = Paginator(products, 12)
    page_number = request.GET.get('page')
    page_obj = paginator.get_page(page_number)

    return render(request, 'shop/product_list.html', {
        'page_obj': page_obj,
        'query': query,
        'selected_tag': selected_tag,
        'sort': sort,
        'total_count': products.count(),
    })


def product_detail(request, pk):
    product = get_object_or_404(Product, pk=pk, is_active=True)
    cart_form = CartAddProductForm()

    # 関連商品 (共通のタグを持つ商品)
    related_products = Product.objects.filter(
        tags__in=product.tags.all(),
        is_active=True
    ).exclude(id=product.id).distinct()[:4]

    is_favorite = False
    if request.user.is_authenticated:
        is_favorite = Favorite.objects.filter(user=request.user, product=product).exists()

    return render(request, 'shop/product_detail.html', {
        'product': product,
        'cart_form': cart_form,
        'related_products': related_products,
        'is_favorite': is_favorite,
    })


@login_required
def product_create(request):
    """商品登録画面 (管理者/スタッフまたは一般ユーザー)"""
    if request.method == 'POST':
        form = ProductForm(request.POST, request.FILES)
        if form.is_valid():
            product = form.save()
            messages.success(request, f"商品「{product.name}」を登録しました。")
            return redirect('shop:product_detail', pk=product.pk)
    else:
        form = ProductForm()

    return render(request, 'shop/product_form.html', {
        'form': form,
        'title': '商品の新規登録',
        'is_edit': False,
    })


@login_required
def product_edit(request, pk):
    product = get_object_or_404(Product, pk=pk)
    if not (request.user.is_staff or request.user.is_superuser):
        messages.error(request, "商品の編集には管理者権限が必要です。")
        return redirect('shop:product_detail', pk=pk)

    if request.method == 'POST':
        form = ProductForm(request.POST, request.FILES, instance=product)
        if form.is_valid():
            product = form.save()
            messages.success(request, f"商品「{product.name}」の情報を更新しました。")
            return redirect('shop:product_detail', pk=product.pk)
    else:
        form = ProductForm(instance=product)

    return render(request, 'shop/product_form.html', {
        'form': form,
        'product': product,
        'title': f'商品編集: {product.name}',
        'is_edit': True,
    })


# -------------------------
# カート機能
# -------------------------

@require_POST
def cart_add(request, product_id):
    cart = Cart(request)
    product = get_object_or_404(Product, id=product_id)
    form = CartAddProductForm(request.POST)

    if form.is_valid():
        cd = form.cleaned_data
        cart.add(
            product=product,
            quantity=cd['quantity'],
            override_quantity=cd['override']
        )
        messages.success(request, f"「{product.name}」をカートに追加しました。")

    return redirect('shop:cart_detail')


@require_POST
def cart_remove(request, product_id):
    cart = Cart(request)
    product = get_object_or_404(Product, id=product_id)
    cart.remove(product)
    messages.info(request, f"「{product.name}」をカートから削除しました。")
    return redirect('shop:cart_detail')


def cart_detail(request):
    cart = Cart(request)
    for item in cart:
        item['update_quantity_form'] = CartAddProductForm(
            initial={'quantity': item['quantity'], 'override': True}
        )
    return render(request, 'shop/cart_detail.html', {'cart': cart})


# -------------------------
# 購入・注文処理
# -------------------------

def checkout(request):
    cart = Cart(request)
    if len(cart) == 0:
        messages.warning(request, "カートが空です。商品を選択してください。")
        return redirect('shop:product_list')

    if request.method == 'POST':
        form = OrderCreateForm(request.POST)
        if form.is_valid():
            with transaction.atomic():
                order = form.save(commit=False)
                if request.user.is_authenticated:
                    order.user = request.user
                
                # ユニークな注文番号の発行
                order.order_number = f"ORD-{uuid.uuid4().hex[:8].upper()}"
                order.total_price = cart.get_total_price()
                order.save()

                for item in cart:
                    product = item['product']
                    quantity = item['quantity']
                    price = item['price']

                    OrderItem.objects.create(
                        order=order,
                        product=product,
                        product_name=product.name,
                        price=price,
                        quantity=quantity
                    )

                    # 在庫を減算（0以下にはならないようガード）
                    if product.stock >= quantity:
                        product.stock -= quantity
                    else:
                        product.stock = 0
                    product.save()

                cart.clear()

            messages.success(request, f"ご注文が完了しました！ 注文番号: #{order.order_number}")
            return redirect('shop:order_complete', order_number=order.order_number)
    else:
        initial_data = {}
        if request.user.is_authenticated:
            initial_data = {
                'full_name': f"{request.user.last_name} {request.user.first_name}".strip() or request.user.username,
                'email': request.user.email,
            }
        form = OrderCreateForm(initial=initial_data)

    return render(request, 'shop/checkout.html', {
        'cart': cart,
        'form': form
    })


def order_complete(request, order_number):
    order = get_object_or_404(Order, order_number=order_number)
    return render(request, 'shop/order_complete.html', {'order': order})


@login_required
def order_list(request):
    orders = Order.objects.filter(user=request.user).order_by('-created_at')
    return render(request, 'shop/order_list.html', {'orders': orders})


@login_required
def order_detail(request, order_number):
    order = get_object_or_404(Order, order_number=order_number, user=request.user)
    return render(request, 'shop/order_detail.html', {'order': order})


# -------------------------
# お気に入り機能
# -------------------------

@login_required
def favorite_toggle(request, product_id):
    product = get_object_or_404(Product, id=product_id)
    fav = Favorite.objects.filter(user=request.user, product=product)

    if fav.exists():
        fav.delete()
        is_favorite = False
        messages.info(request, f"「{product.name}」をお気に入りから解除しました。")
    else:
        Favorite.objects.create(user=request.user, product=product)
        is_favorite = True
        messages.success(request, f"「{product.name}」をお気に入りに追加しました。")

    if request.headers.get('x-requested-with') == 'XMLHttpRequest':
        favorite_count = Favorite.objects.filter(user=request.user).count()
        return JsonResponse({
            'status': 'ok',
            'is_favorite': is_favorite,
            'favorite_count': favorite_count
        })

    next_url = request.META.get('HTTP_REFERER') or 'shop:product_list'
    return redirect(next_url)


@login_required
def favorite_list(request):
    favorites = Favorite.objects.filter(user=request.user).select_related('product')
    return render(request, 'shop/favorite_list.html', {'favorites': favorites})


# -------------------------
# 認証・マイページ
# -------------------------

def signup_view(request):
    if request.user.is_authenticated:
        return redirect('shop:product_list')

    if request.method == 'POST':
        form = SignUpForm(request.POST)
        if form.is_valid():
            user = form.save()
            login(request, user)
            messages.success(request, f"アカウントの登録が完了しました。ようこそ、{user.username}様！")
            return redirect('shop:product_list')
    else:
        form = SignUpForm()

    return render(request, 'shop/signup.html', {'form': form})


def login_view(request):
    if request.user.is_authenticated:
        return redirect('shop:product_list')

    if request.method == 'POST':
        form = AuthenticationForm(request, data=request.POST)
        if form.is_valid():
            user = form.get_user()
            login(request, user)
            messages.success(request, f"ログインしました。お帰りなさい、{user.username}様！")
            next_url = request.GET.get('next') or 'shop:product_list'
            return redirect(next_url)
        else:
            messages.error(request, "ユーザー名またはパスワードが正しくありません。")
    else:
        form = AuthenticationForm()

    return render(request, 'shop/login.html', {'form': form})


def logout_view(request):
    logout(request)
    messages.info(request, "ログアウトしました。")
    return redirect('shop:product_list')


@login_required
def mypage_view(request):
    recent_orders = Order.objects.filter(user=request.user)[:5]
    favorites = Favorite.objects.filter(user=request.user).select_related('product')[:6]
    return render(request, 'shop/mypage.html', {
        'recent_orders': recent_orders,
        'favorites': favorites,
    })
