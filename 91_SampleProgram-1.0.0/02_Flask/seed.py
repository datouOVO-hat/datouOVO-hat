import os, random
from app import create_app, db
from app.models import User, Tag, Product, Order, OrderItem, Favorite

app = create_app()

with app.app_context():
    db.create_all()

    # 1. ユーザー作成
    if not User.query.filter_by(username='admin').first():
        u = User(username='admin', email='admin@example.com', first_name='管理者', last_name='システム', is_staff=True)
        u.set_password('admin123')
        db.session.add(u)

    if not User.query.filter_by(username='student').first():
        u = User(username='student', email='student@example.com', first_name='太郎', last_name='学生', is_staff=False)
        u.set_password('student123')
        db.session.add(u)

    # 2. タグ作成
    tag_defs = [
        ('レディース', 'lady', 'danger'),
        ('メンズ', 'men', 'primary'),
        ('バッグ', 'bag', 'warning'),
        ('アウター', 'outer', 'dark'),
        ('ワンピース', 'onepiece', 'danger'),
        ('シューズ', 'shoes', 'info'),
        ('スカート', 'skirt', 'warning'),
        ('トップス', 'tops', 'success'),
        ('ファッション小物', 'fashion_etc', 'secondary'),
        ('小説・書籍', 'novel', 'primary'),
        ('ヴィンテージ・古着', 'vintage', 'dark')
    ]
    tag_map = {}
    for name, slug, color in tag_defs:
        t = Tag.query.filter_by(slug=slug).first()
        if not t:
            t = Tag(name=name, slug=slug, color=color)
            db.session.add(t)
        tag_map[slug] = t
    db.session.commit()

    # 3. 商品作成 (media/products 内の画像をスキャン)
    cat_meta = {
        'bag_lady': (['lady', 'bag'], 'ナチュラルレザートートバッグ', 9800),
        'fashion_etc_lady': (['lady', 'fashion_etc'], 'オーガニックコットンストール', 3800),
        'novel': (['novel'], '北欧ライフスタイルエッセイ', 1600),
        'old': (['vintage'], 'アンティークウッドカトラリー', 4500),
        'onepiece_lady': (['lady', 'onepiece'], 'リネンブレンドワンピース', 8900),
        'outer_lady': (['lady', 'outer'], 'ナチュラルウールニットジャケット', 14800),
        'outer_men': (['men', 'outer'], 'メンズキャンバスブルゾン', 13500),
        'pants_men': (['men'], 'オーガニックコットンチノ', 6900),
        'shoes_lady': (['lady', 'shoes'], 'コンフォートフラットレザーシューズ', 9200),
        'skirt_lady': (['lady', 'skirt'], 'リネンギャザースカート', 6400),
        'tops_lady': (['lady', 'tops'], 'ワッフルニットプルオーバー', 5200),
        'tops_men': (['men', 'tops'], 'バンドカラーオックスフォードシャツ', 5800)
    }

    media_dir = os.path.abspath('app/media/products')
    for folder, (tags, base_name, base_price) in cat_meta.items():
        f_path = os.path.join(media_dir, folder)
        if os.path.exists(f_path):
            imgs = [img for img in os.listdir(f_path) if img.lower().endswith(('.jpg', '.png'))][:3]
            for i, img in enumerate(imgs, 1):
                p_name = f"{base_name} #{i}"
                if not Product.query.filter_by(name=p_name).first():
                    prod = Product(
                        name=p_name,
                        description='肌触りと着心地にこだわったナチュラルなデイリーアイテム。',
                        price=base_price + (i * 200),
                        stock=random.randint(5, 20),
                        image=f"products/{folder}/{img}",
                        is_active=True
                    )
                    prod.tags = [tag_map[slug] for slug in tags if slug in tag_map]
                    db.session.add(prod)

    # 4. 画像なし商品
    if not Product.query.filter_by(name='【入荷予約】手編みウールブランケット').first():
        p_no = Product(name='【入荷予約】手編みウールブランケット', description='画像準備中ですが先行予約受付中。', price=8500, stock=3, image=None, is_active=True)
        p_no.tags = [tag_map['fashion_etc']]
        db.session.add(p_no)

    db.session.commit()
    print("Flask Seed data loaded successfully!")
