import os
import random
from pathlib import Path
from django.core.management.base import BaseCommand
from django.contrib.auth.models import User
from django.conf import settings
from shop.models import Tag, Product, Order, OrderItem, Favorite


class Command(BaseCommand):
    help = "Loads sample products, tags, users, and orders using images in media/products."

    def handle(self, *args, **kwargs):
        self.stdout.write(self.style.NOTICE("=== サンプルデータの初期化を開始します ==="))

        # 1. ユーザーの作成
        admin_user, created = User.objects.get_or_create(username='admin', defaults={
            'email': 'admin@example.com',
            'is_staff': True,
            'is_superuser': True,
            'first_name': '管理者',
            'last_name': 'システム',
        })
        if created:
            admin_user.set_password('admin123')
            admin_user.save()
            self.stdout.write(self.style.SUCCESS("管理者ユーザーを作成しました: admin / admin123"))

        student_user, created = User.objects.get_or_create(username='student', defaults={
            'email': 'student@example.com',
            'first_name': '太郎',
            'last_name': '学生',
        })
        if created:
            student_user.set_password('student123')
            student_user.save()
            self.stdout.write(self.style.SUCCESS("演習用学生ユーザーを作成しました: student / student123"))

        # 2. タグの定義
        tag_definitions = [
            {'name': 'レディース', 'slug': 'lady', 'color': 'danger'},
            {'name': 'メンズ', 'slug': 'men', 'color': 'primary'},
            {'name': 'バッグ', 'slug': 'bag', 'color': 'warning'},
            {'name': 'アウター', 'slug': 'outer', 'color': 'dark'},
            {'name': 'ワンピース', 'slug': 'onepiece', 'color': 'danger'},
            {'name': 'シューズ', 'slug': 'shoes', 'color': 'info'},
            {'name': 'スカート', 'slug': 'skirt', 'color': 'warning'},
            {'name': 'トップス', 'slug': 'tops', 'color': 'success'},
            {'name': 'ファッション小物', 'slug': 'fashion_etc', 'color': 'secondary'},
            {'name': '小説・書籍', 'slug': 'novel', 'color': 'primary'},
            {'name': 'ヴィンテージ・古着', 'slug': 'vintage', 'color': 'dark'},
        ]

        tag_map = {}
        for td in tag_definitions:
            tag, _ = Tag.objects.get_or_create(slug=td['slug'], defaults={'name': td['name'], 'color': td['color']})
            tag_map[td['slug']] = tag

        self.stdout.write(self.style.SUCCESS(f"{len(tag_map)} 件のタグを準備しました。"))

        # 3. フォルダごとの商品設定
        category_meta = {
            'bag_lady': {
                'tags': ['lady', 'bag'],
                'base_name': 'レディース デザイナーズバッグ',
                'desc': '上質な素材を使用した使い勝手の良いデザインバッグ。ビジネスから普段使いまで幅広く活躍します。',
                'price_range': (4800, 15800),
            },
            'fashion_etc_lady': {
                'tags': ['lady', 'fashion_etc'],
                'base_name': 'エレガント ファッション小物',
                'desc': 'コーディネートのワンポイントに映える洗練されたアクセサリー・ファッション雑貨です。',
                'price_range': (2200, 6800),
            },
            'novel': {
                'tags': ['novel'],
                'base_name': 'ベストセラー文芸小説',
                'desc': '深い物語と感動が広がる注目の話題作。休日の読書やリラックスタイムに最適な一冊。',
                'price_range': (1200, 2400),
            },
            'old': {
                'tags': ['vintage'],
                'base_name': 'クラシック・ヴィンテージセレクション',
                'desc': '一点ものの味わい深いヴィンテージアイテム。時代を超えて愛されるレトロな風合いが魅力です。',
                'price_range': (6500, 24800),
            },
            'onepiece_lady': {
                'tags': ['lady', 'onepiece'],
                'base_name': 'スタイリッシュ ワンピース',
                'desc': '美しいシルエットと軽やかな着心地を両立したワンピース。季節を問わず着用いただけます。',
                'price_range': (5800, 14200),
            },
            'outer_lady': {
                'tags': ['lady', 'outer'],
                'base_name': 'レディース トレンドアウター',
                'desc': '防寒性とデザイン性を兼ね備えた秋冬必須の高品質アウターコート。',
                'price_range': (8900, 29800),
            },
            'outer_men': {
                'tags': ['men', 'outer'],
                'base_name': 'メンズ カジュアルジャケット/コート',
                'desc': '着回し力抜群のメンズアウター。耐久性のあるファブリックで長年愛用できます。',
                'price_range': (9800, 32000),
            },
            'pants_men': {
                'tags': ['men'],
                'base_name': 'メンズ テーラードパンツ/スラックス',
                'desc': '美しいシルエットと快適なストレッチ性を両立したメンズボトムス。',
                'price_range': (4900, 11800),
            },
            'shoes_lady': {
                'tags': ['lady', 'shoes'],
                'base_name': 'レディース コンフォートシューズ',
                'desc': '歩きやすさと上品さを兼備した高品質シューズ。デイリーユースにぴったりです。',
                'price_range': (5400, 16800),
            },
            'skirt_lady': {
                'tags': ['lady', 'skirt'],
                'base_name': 'フレア＆タイトスカート',
                'desc': '女性らしい揺れ感と上品なドレープ感が魅力のデザイナースカート。',
                'price_range': (3900, 9800),
            },
            'tops_lady': {
                'tags': ['lady', 'tops'],
                'base_name': 'レディース プレミアムトップス',
                'desc': '肌触りの良いオーガニックコットンと丁寧な縫製で作られた着心地抜群のトップス。',
                'price_range': (3200, 8500),
            },
            'tops_men': {
                'tags': ['men', 'tops'],
                'base_name': 'メンズ クラシックシャツ/ニット',
                'desc': 'シンプルながら細部にこだわった定番メンズトップス。1枚でもインナーでも決まります。',
                'price_range': (3500, 8900),
            },
        }

        media_products_dir = Path(settings.MEDIA_ROOT) / 'products'
        created_count = 0

        # 各フォルダから数枚ずつ登録（多すぎず、ページネーションが活きる30〜40件程度を生成）
        for folder_name, meta in category_meta.items():
            folder_path = media_products_dir / folder_name
            if not folder_path.exists():
                continue

            images = [f for f in os.listdir(folder_path) if f.lower().endswith(('.jpg', '.jpeg', '.png', '.webp'))]
            # 各フォルダから最大3枚選出
            selected_images = images[:3]

            for idx, img_name in enumerate(selected_images, start=1):
                p_name = f"{meta['base_name']} Model #{idx}"
                if Product.objects.filter(name=p_name).exists():
                    continue

                price = random.randint(meta['price_range'][0] // 100, meta['price_range'][1] // 100) * 100
                stock = random.randint(3, 25)
                rel_img_path = f"products/{folder_name}/{img_name}"

                product = Product.objects.create(
                    name=p_name,
                    description=f"{meta['desc']}\n\n■ 特徴\n・素材: 高機能プレミアム素材\n・原産国: 日本/イタリア企画\n・取扱: 洗濯機弱または手洗い可\n・サイズ: フリー / M相当",
                    price=price,
                    stock=stock,
                    image=rel_img_path,
                    is_active=True
                )
                for t_slug in meta['tags']:
                    if t_slug in tag_map:
                        product.tags.add(tag_map[t_slug])

                created_count += 1

        # 4. 画像なし商品（no-image.png がフォールバックされる検証用商品）
        no_image_samples = [
            {
                'name': '【画像準備中】限定コラボレーション パーカー',
                'description': '次回入荷予定の新作コラボレーション限定アイテムです。画像は現在準備中ですが、予約受付中です。',
                'price': 12000,
                'stock': 5,
                'tags': ['tops', 'men'],
            },
            {
                'name': '【サンプル品】ハンドメイド レザーキーケース',
                'description': '職人が手縫いで仕上げた一点物レザー小物。画像未登録のため特別価格にてご提供。',
                'price': 2500,
                'stock': 8,
                'tags': ['fashion_etc'],
            },
        ]

        for nis in no_image_samples:
            if not Product.objects.filter(name=nis['name']).exists():
                p = Product.objects.create(
                    name=nis['name'],
                    description=nis['description'],
                    price=nis['price'],
                    stock=nis['stock'],
                    image=None,  # 未設定 -> no-image.png が適用される
                    is_active=True
                )
                for t_slug in nis['tags']:
                    if t_slug in tag_map:
                        p.tags.add(tag_map[t_slug])
                created_count += 1

        self.stdout.write(self.style.SUCCESS(f"合計 {created_count} 件の商品を登録しました。"))

        # 5. テスト用注文データとお気に入りの作成
        all_products = list(Product.objects.all())
        if all_products and student_user:
            # お気に入り登録
            for p in all_products[:4]:
                Favorite.objects.get_or_create(user=student_user, product=p)
            self.stdout.write(self.style.SUCCESS("studentユーザーのお気に入りデータを追加しました。"))

            # 過去の注文データ
            if not Order.objects.filter(user=student_user).exists():
                order = Order.objects.create(
                    user=student_user,
                    order_number="ORD-SAMPLE2026",
                    full_name="学生 太郎",
                    postal_code="150-0002",
                    address="東京都渋谷区渋谷1-2-3 演習ビル5F",
                    phone_number="090-9999-8888",
                    email="student@example.com",
                    payment_method="credit_card",
                    status="completed",
                    total_price=0
                )
                total = 0
                for p in all_products[:2]:
                    OrderItem.objects.create(
                        order=order,
                        product=p,
                        product_name=p.name,
                        price=p.price,
                        quantity=1
                    )
                    total += p.price
                order.total_price = total
                order.save()
                self.stdout.write(self.style.SUCCESS("studentユーザーのサンプル注文履歴を作成しました。"))

        self.stdout.write(self.style.SUCCESS("=== サンプルデータの初期化が正常に完了しました！ ==="))
