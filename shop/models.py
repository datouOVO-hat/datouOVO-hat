import os
from django.db import models
from django.contrib.auth.models import User
from django.conf import settings


class Tag(models.Model):
    COLOR_CHOICES = [
        ('primary', 'Primary (Blue)'),
        ('secondary', 'Secondary (Gray)'),
        ('success', 'Success (Green)'),
        ('danger', 'Danger (Red)'),
        ('warning', 'Warning (Yellow)'),
        ('info', 'Info (Teal)'),
        ('dark', 'Dark (Black)'),
    ]

    name = models.CharField(max_length=50, unique=True, verbose_name="タグ名")
    slug = models.SlugField(max_length=50, unique=True, allow_unicode=True, verbose_name="スラグ")
    color = models.CharField(max_length=20, choices=COLOR_CHOICES, default='primary', verbose_name="バッジ色")

    class Meta:
        verbose_name = "タグ"
        verbose_name_plural = "タグ一覧"
        ordering = ['name']

    def __str__(self):
        return self.name


class Product(models.Model):
    name = models.CharField(max_length=200, verbose_name="商品名")
    description = models.TextField(blank=True, verbose_name="商品説明")
    price = models.PositiveIntegerField(default=0, verbose_name="価格 (円)")
    stock = models.PositiveIntegerField(default=10, verbose_name="在庫数")
    image = models.ImageField(upload_to='products/', blank=True, null=True, verbose_name="商品画像")
    tags = models.ManyToManyField(Tag, blank=True, related_name='products', verbose_name="タグ")
    is_active = models.BooleanField(default=True, verbose_name="公開状態")
    created_at = models.DateTimeField(auto_now_add=True, verbose_name="登録日時")
    updated_at = models.DateTimeField(auto_now=True, verbose_name="更新日時")

    class Meta:
        verbose_name = "商品"
        verbose_name_plural = "商品一覧"
        ordering = ['-created_at']

    def __str__(self):
        return self.name

    @property
    def image_url(self):
        """画像が存在しない、または未登録の場合は no-image.png を返す"""
        if self.image:
            image_path = os.path.join(settings.MEDIA_ROOT, self.image.name)
            if os.path.exists(image_path):
                return self.image.url
        return f"{settings.MEDIA_URL}no-image.png"

    @property
    def is_in_stock(self):
        return self.stock > 0


class Order(models.Model):
    PAYMENT_METHODS = [
        ('credit_card', 'クレジットカード決済'),
        ('bank_transfer', '銀行振込'),
        ('cod', '代金引換'),
        ('convenience', 'コンビニ決済'),
    ]

    STATUS_CHOICES = [
        ('pending', '処理待ち'),
        ('processing', '発送準備中'),
        ('shipped', '発送済み'),
        ('completed', '配達完了'),
        ('cancelled', 'キャンセル'),
    ]

    user = models.ForeignKey(
        User, on_delete=models.SET_NULL, null=True, blank=True,
        related_name='orders', verbose_name="購入ユーザー"
    )
    order_number = models.CharField(max_length=32, unique=True, verbose_name="注文番号")
    full_name = models.CharField(max_length=100, verbose_name="氏名")
    postal_code = models.CharField(max_length=10, verbose_name="郵便番号")
    address = models.CharField(max_length=255, verbose_name="配送先住所")
    phone_number = models.CharField(max_length=20, verbose_name="電話番号")
    email = models.EmailField(verbose_name="メールアドレス")
    payment_method = models.CharField(
        max_length=20, choices=PAYMENT_METHODS, default='credit_card', verbose_name="支払方法"
    )
    total_price = models.PositiveIntegerField(default=0, verbose_name="合計金額 (円)")
    status = models.CharField(
        max_length=20, choices=STATUS_CHOICES, default='completed', verbose_name="注文ステータス"
    )
    created_at = models.DateTimeField(auto_now_add=True, verbose_name="注文日時")

    class Meta:
        verbose_name = "注文"
        verbose_name_plural = "注文履歴"
        ordering = ['-created_at']

    def __str__(self):
        return f"Order #{self.order_number} ({self.full_name})"


class OrderItem(models.Model):
    order = models.ForeignKey(Order, on_delete=models.CASCADE, related_name='items', verbose_name="注文")
    product = models.ForeignKey(Product, on_delete=models.SET_NULL, null=True, blank=True, verbose_name="商品")
    product_name = models.CharField(max_length=200, verbose_name="購入時商品名")
    price = models.PositiveIntegerField(default=0, verbose_name="購入時単価")
    quantity = models.PositiveIntegerField(default=1, verbose_name="数量")

    class Meta:
        verbose_name = "注文明細"
        verbose_name_plural = "注文明細一覧"

    @property
    def subtotal(self):
        return self.price * self.quantity

    def __str__(self):
        return f"{self.product_name} x {self.quantity}"


class Favorite(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='favorites', verbose_name="ユーザー")
    product = models.ForeignKey(Product, on_delete=models.CASCADE, related_name='favorited_by', verbose_name="商品")
    created_at = models.DateTimeField(auto_now_add=True, verbose_name="登録日時")

    class Meta:
        verbose_name = "お気に入り"
        verbose_name_plural = "お気に入り一覧"
        unique_together = ('user', 'product')
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.user.username} - {self.product.name}"
