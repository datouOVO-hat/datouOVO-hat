from copy import deepcopy
from app.models import Product

class Cart:
    def __init__(self, session):
        self.session = session
        cart = self.session.get('cart')
        if not cart:
            cart = self.session['cart'] = {}
        self.cart = cart

    def add(self, product, quantity=1, override=False):
        p_id = str(product.id)
        if p_id not in self.cart:
            self.cart[p_id] = {'quantity': 0, 'price': int(product.price)}
        if override:
            self.cart[p_id]['quantity'] = quantity
        else:
            self.cart[p_id]['quantity'] += quantity
        if self.cart[p_id]['quantity'] <= 0:
            self.remove(product)
        else:
            self.save()

    def remove(self, product):
        p_id = str(product.id)
        if p_id in self.cart:
            del self.cart[p_id]
            self.save()

    def update(self, product_id, quantity):
        p_id = str(product_id)
        if p_id in self.cart:
            if quantity <= 0:
                del self.cart[p_id]
            else:
                self.cart[p_id]['quantity'] = quantity
            self.save()

    def clear(self):
        self.session.pop('cart', None)
        self.session.modified = True

    def save(self):
        self.session.modified = True

    def __iter__(self):
        # session['cart'] にはシリアライズ不能な Product オブジェクトを代入せず、
        # 反復処理用の独立した辞書オブジェクトを生成して yield する
        p_ids = [int(k) for k in self.cart.keys()]
        products = {p.id: p for p in Product.query.filter(Product.id.in_(p_ids)).all()}
        
        for k, v in list(self.cart.items()):
            p_id = int(k)
            if p_id in products:
                yield {
                    'product': products[p_id],
                    'quantity': v['quantity'],
                    'price': v['price'],
                    'total_price': v['price'] * v['quantity']
                }

    def __len__(self):
        return sum(item['quantity'] for item in self.cart.values())

    @property
    def total_price(self):
        return sum(int(item['price']) * item['quantity'] for item in self.cart.values())

    @property
    def is_empty(self):
        return len(self.cart) == 0
