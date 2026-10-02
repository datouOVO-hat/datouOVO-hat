import uuid, os
from flask import Blueprint, render_template, request, redirect, url_for, flash, session, send_from_directory
from flask_login import login_user, logout_user, login_required, current_user
from app import db
from app.models import Product, Tag, Order, OrderItem, Favorite, User
from app.cart import Cart

main_bp = Blueprint('main', __name__)

@main_bp.app_context_processor
def inject_context():
    cart = Cart(session)
    all_tags = Tag.query.order_by(Tag.name).all()
    favorite_count = 0
    favorite_product_ids = []
    if current_user.is_authenticated:
        favs = Favorite.query.filter_by(user_id=current_user.id).all()
        favorite_count = len(favs)
        favorite_product_ids = [f.product_id for f in favs]
    return {
        'cart': cart,
        'cart_count': len(cart),
        'all_tags': all_tags,
        'favorite_count': favorite_count,
        'favorite_product_ids': favorite_product_ids
    }

@main_bp.route('/media/<path:filename>')
def media_file(filename):
    return send_from_directory(os.path.abspath('app/media'), filename)

@main_bp.route('/')
@main_bp.route('/products')
def product_list():
    query = request.args.get('q', '').strip()
    tag_slug = request.args.get('tag', '').strip()
    sort = request.args.get('sort', 'newest')
    page = request.args.get('page', 1, type=int)

    stmt = Product.query.filter_by(is_active=True)
    selected_tag = None
    if tag_slug:
        selected_tag = Tag.query.filter_by(slug=tag_slug).first()
        if selected_tag:
            stmt = stmt.filter(Product.tags.contains(selected_tag))

    if query:
        stmt = stmt.filter(Product.name.ilike(f"%{query}%") | Product.description.ilike(f"%{query}%"))

    if sort == 'price_asc':
        stmt = stmt.order_by(Product.price.asc())
    elif sort == 'price_desc':
        stmt = stmt.order_by(Product.price.desc())
    else:
        stmt = stmt.order_by(Product.created_at.desc())

    pagination = stmt.paginate(page=page, per_page=12, error_out=False)

    return render_template('product/list.html',
                           products=pagination.items,
                           pagination=pagination,
                           query=query,
                           tag_slug=tag_slug,
                           selected_tag=selected_tag,
                           sort=sort)

@main_bp.route('/products/<int:id>')
def product_detail(id):
    product = Product.query.get_or_404(id)
    related = Product.query.filter(
        Product.tags.any(Tag.id.in_([t.id for t in product.tags])),
        Product.id != product.id,
        Product.is_active == True
    ).limit(4).all()
    return render_template('product/detail.html', product=product, related_products=related)

@main_bp.route('/products/create', methods=['GET', 'POST'])
@login_required
def product_create():
    if request.method == 'POST':
        name = request.form.get('name')
        description = request.form.get('description')
        price = int(request.form.get('price', 0))
        stock = int(request.form.get('stock', 10))
        image = request.form.get('image', '').strip() or None
        tag_ids = request.form.getlist('tag_ids', type=int)

        p = Product(name=name, description=description, price=price, stock=stock, image=image, is_active=True)
        if tag_ids:
            tags = Tag.query.filter(Tag.id.in_(tag_ids)).all()
            p.tags = tags

        db.session.add(p)
        db.session.commit()
        flash(f"アイテム「{p.name}」を出品・登録いたしました。", "success")
        return redirect(url_for('main.product_detail', id=p.id))

    return render_template('product/form.html')

@main_bp.route('/cart')
def cart_detail():
    cart = Cart(session)
    return render_template('cart/cart.html', cart=cart)

@main_bp.route('/cart/add/<int:product_id>', methods=['POST'])
def cart_add(product_id):
    cart = Cart(session)
    product = Product.query.get_or_404(product_id)
    qty = request.form.get('quantity', 1, type=int)
    cart.add(product, qty)
    flash(f"「{product.name}」をバスケットに追加しました。", "success")
    return redirect(url_for('main.cart_detail'))

@main_bp.route('/cart/update/<int:product_id>', methods=['POST'])
def cart_update(product_id):
    cart = Cart(session)
    qty = request.form.get('quantity', 1, type=int)
    cart.update(product_id, qty)
    return redirect(url_for('main.cart_detail'))

@main_bp.route('/cart/remove/<int:product_id>', methods=['POST'])
def cart_remove(product_id):
    cart = Cart(session)
    product = Product.query.get_or_404(product_id)
    cart.remove(product)
    flash(f"「{product.name}」をバスケットから削除しました。", "info")
    return redirect(url_for('main.cart_detail'))

@main_bp.route('/checkout', methods=['GET', 'POST'])
def checkout():
    cart = Cart(session)
    if cart.is_empty:
        flash("バスケットに商品が入っていません。", "warning")
        return redirect(url_for('main.product_list'))

    if request.method == 'POST':
        order_num = f"ORD-{uuid.uuid4().hex[:8].upper()}"
        order = Order(
            user_id=current_user.id if current_user.is_authenticated else None,
            order_number=order_num,
            full_name=request.form.get('full_name'),
            postal_code=request.form.get('postal_code'),
            address=request.form.get('address'),
            phone_number=request.form.get('phone_number'),
            email=request.form.get('email'),
            payment_method=request.form.get('payment_method', 'credit_card'),
            total_price=cart.total_price,
            status='completed'
        )
        db.session.add(order)

        for item in cart:
            p = item['product']
            oi = OrderItem(
                order=order,
                product_id=p.id,
                product_name=p.name,
                price=item['price'],
                quantity=item['quantity']
            )
            db.session.add(oi)
            if p.stock >= item['quantity']:
                p.stock -= item['quantity']
            else:
                p.stock = 0

        db.session.commit()
        cart.clear()
        flash("ご注文が完了いたしました。", "success")
        return redirect(url_for('main.order_complete', order_number=order_num))

    return render_template('order/checkout.html', cart=cart)

@main_bp.route('/checkout/complete/<string:order_number>')
def order_complete(order_number):
    order = Order.query.filter_by(order_number=order_number).first_or_404()
    return render_template('order/complete.html', order=order)

@main_bp.route('/orders')
@login_required
def order_list():
    orders = Order.query.filter_by(user_id=current_user.id).order_by(Order.created_at.desc()).all()
    return render_template('order/list.html', orders=orders)

@main_bp.route('/orders/<string:order_number>')
@login_required
def order_detail(order_number):
    order = Order.query.filter_by(order_number=order_number, user_id=current_user.id).first_or_404()
    return render_template('order/detail.html', order=order)

@main_bp.route('/favorites/toggle/<int:product_id>', methods=['POST'])
@login_required
def favorite_toggle(product_id):
    product = Product.query.get_or_404(product_id)
    fav = Favorite.query.filter_by(user_id=current_user.id, product_id=product.id).first()
    if fav:
        db.session.delete(fav)
        flash(f"「{product.name}」をお気に入りから解除しました。", "info")
    else:
        db.session.add(Favorite(user_id=current_user.id, product_id=product.id))
        flash(f"「{product.name}」をお気に入りに追加しました。", "success")
    db.session.commit()
    return redirect(request.referrer or url_for('main.product_list'))

@main_bp.route('/favorites')
@login_required
def favorite_list():
    favorites = Favorite.query.filter_by(user_id=current_user.id).all()
    return render_template('favorite/list.html', favorites=favorites)

@main_bp.route('/login', methods=['GET', 'POST'])
def login():
    if current_user.is_authenticated:
        return redirect(url_for('main.product_list'))
    if request.method == 'POST':
        u = request.form.get('username')
        p = request.form.get('password')
        user = User.query.filter_by(username=u).first()
        if user and user.check_password(p):
            login_user(user)
            flash(f"ようこそ、{user.username}様。", "success")
            return redirect(url_for('main.product_list'))
        flash("ユーザー名またはパスワードが正しくありません。", "danger")
    return render_template('auth/login.html')

@main_bp.route('/signup', methods=['GET', 'POST'])
def signup():
    if current_user.is_authenticated:
        return redirect(url_for('main.product_list'))
    if request.method == 'POST':
        u = request.form.get('username')
        p = request.form.get('password')
        e = request.form.get('email')
        f = request.form.get('first_name')
        l = request.form.get('last_name')
        if User.query.filter_by(username=u).first():
            flash("このユーザー名は既に使用されています。", "danger")
            return render_template('auth/signup.html')
        user = User(username=u, email=e, first_name=f, last_name=l, is_staff=False)
        user.set_password(p)
        db.session.add(user)
        db.session.commit()
        login_user(user)
        flash(f"会員登録が完了しました。exShop Nordicへようこそ！", "success")
        return redirect(url_for('main.product_list'))
    return render_template('auth/signup.html')

@main_bp.route('/logout')
def logout():
    logout_user()
    flash("ログアウトしました。", "info")
    return redirect(url_for('main.product_list'))

@main_bp.route('/mypage')
@login_required
def mypage():
    recent_orders = Order.query.filter_by(user_id=current_user.id).order_by(Order.created_at.desc()).limit(5).all()
    favorites = Favorite.query.filter_by(user_id=current_user.id).limit(6).all()
    return render_template('auth/mypage.html', recent_orders=recent_orders, favorites=favorites)
