from shop.cart import Cart
from shop.models import Tag, Favorite


def shop_context(request):
    cart = Cart(request)
    all_tags = Tag.objects.all()
    
    favorite_count = 0
    favorite_product_ids = []
    if request.user.is_authenticated:
        favs = Favorite.objects.filter(user=request.user)
        favorite_count = favs.count()
        favorite_product_ids = list(favs.values_list('product_id', flat=True))

    return {
        'cart': cart,
        'cart_item_count': len(cart),
        'all_tags': all_tags,
        'favorite_count': favorite_count,
        'favorite_product_ids': favorite_product_ids,
    }
