from django import forms
from django.contrib.auth.models import User
from django.contrib.auth.forms import UserCreationForm
from shop.models import Product, Order, Tag


class SignUpForm(UserCreationForm):
    first_name = forms.CharField(max_length=30, required=True, label="名")
    last_name = forms.CharField(max_length=30, required=True, label="姓")
    email = forms.EmailField(max_length=254, required=True, label="メールアドレス")

    class Meta(UserCreationForm.Meta):
        model = User
        fields = ('username', 'last_name', 'first_name', 'email')

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        for field in self.fields.values():
            field.widget.attrs.update({'class': 'form-control'})


class ProductForm(forms.ModelForm):
    tags = forms.ModelMultipleChoiceField(
        queryset=Tag.objects.all(),
        widget=forms.CheckboxSelectMultiple,
        required=False,
        label="関連タグ"
    )

    class Meta:
        model = Product
        fields = ['name', 'description', 'price', 'stock', 'image', 'tags', 'is_active']
        widgets = {
            'name': forms.TextInput(attrs={'class': 'form-control', 'placeholder': '例: クラシック レザートートバッグ'}),
            'description': forms.Textarea(attrs={'class': 'form-control', 'rows': 4, 'placeholder': '商品の特徴、サイズ、素材などを入力'}),
            'price': forms.NumberInput(attrs={'class': 'form-control', 'min': 0, 'step': 10}),
            'stock': forms.NumberInput(attrs={'class': 'form-control', 'min': 0}),
            'image': forms.ClearableFileInput(attrs={'class': 'form-control'}),
            'is_active': forms.CheckboxInput(attrs={'class': 'form-check-input'}),
        }


class OrderCreateForm(forms.ModelForm):
    class Meta:
        model = Order
        fields = ['full_name', 'postal_code', 'address', 'phone_number', 'email', 'payment_method']
        widgets = {
            'full_name': forms.TextInput(attrs={'class': 'form-control', 'placeholder': '山田 太郎'}),
            'postal_code': forms.TextInput(attrs={'class': 'form-control', 'placeholder': '100-0001'}),
            'address': forms.TextInput(attrs={'class': 'form-control', 'placeholder': '東京都千代田区千代田1-1 ○○マンション101'}),
            'phone_number': forms.TextInput(attrs={'class': 'form-control', 'placeholder': '090-1234-5678'}),
            'email': forms.EmailInput(attrs={'class': 'form-control', 'placeholder': 'yamada@example.com'}),
            'payment_method': forms.Select(attrs={'class': 'form-select'}),
        }


class CartAddProductForm(forms.Form):
    quantity = forms.IntegerField(
        min_value=1,
        initial=1,
        widget=forms.NumberInput(attrs={'class': 'form-control form-control-sm text-center', 'style': 'max-width: 80px;'})
    )
    override = forms.BooleanField(required=False, initial=False, widget=forms.HiddenInput)
