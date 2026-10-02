from django.urls import path
from shop import views

app_name = 'shop'

urlpatterns = [
    # 商品
    path('', views.product_list, name='product_list'),
    path('products/<int:pk>/', views.product_detail, name='product_detail'),
    path('products/add/', views.product_create, name='product_create'),
    path('products/<int:pk>/edit/', views.product_edit, name='product_edit'),

    # カート
    path('cart/', views.cart_detail, name='cart_detail'),
    path('cart/add/<int:product_id>/', views.cart_add, name='cart_add'),
    path('cart/remove/<int:product_id>/', views.cart_remove, name='cart_remove'),

    # 購入・注文
    path('checkout/', views.checkout, name='checkout'),
    path('orders/complete/<str:order_number>/', views.order_complete, name='order_complete'),
    path('orders/', views.order_list, name='order_list'),
    path('orders/<str:order_number>/', views.order_detail, name='order_detail'),

    # お気に入り
    path('favorites/', views.favorite_list, name='favorite_list'),
    path('favorites/toggle/<int:product_id>/', views.favorite_toggle, name='favorite_toggle'),

    # 認証・マイページ
    path('signup/', views.signup_view, name='signup'),
    path('login/', views.login_view, name='login'),
    path('logout/', views.logout_view, name='logout'),
    path('mypage/', views.mypage_view, name='mypage'),
]
