-- ============================================================
-- exShop Sample Seed Data for PostgreSQL
-- ============================================================

-- 1. ユーザー初期データ (パスワード: BCryptハッシュ)
-- admin: admin123  ($2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy)
-- student: student123 ($2a$10$7zBqmD6pB882mX7jXh1Mre5e9h8Y22R37L39O/V5m7Y1/J.w3.O6S)
INSERT INTO users (id, username, password_hash, email, first_name, last_name, is_staff) VALUES
(1, 'admin', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'admin@example.com', '管理者', 'システム', TRUE),
(2, 'student', '$2a$10$7zBqmD6pB882mX7jXh1Mre5e9h8Y22R37L39O/V5m7Y1/J.w3.O6S', 'student@example.com', '太郎', '学生', FALSE);

-- 2. タグ初期データ
INSERT INTO tags (id, name, slug, color) VALUES
(1, 'レディース', 'lady', 'danger'),
(2, 'メンズ', 'men', 'primary'),
(3, 'バッグ', 'bag', 'warning'),
(4, 'アウター', 'outer', 'dark'),
(5, 'ワンピース', 'onepiece', 'danger'),
(6, 'シューズ', 'shoes', 'info'),
(7, 'スカート', 'skirt', 'warning'),
(8, 'トップス', 'tops', 'success'),
(9, 'ファッション小物', 'fashion_etc', 'secondary'),
(10, '小説・書籍', 'novel', 'primary'),
(11, 'ヴィンテージ・古着', 'vintage', 'dark');

-- 3. 商品初期データ (38件)
INSERT INTO products (id, name, description, price, stock, image, is_active) VALUES
(1, 'レディース デザイナーズバッグ Model #1', '上質なサフィアーノレザーを使用したエレガントなハンドバッグ。ゴールド金具が高級感を演出します。', 12800, 15, 'products/bag_lady/Image_fx (1).jpg', TRUE),
(2, 'レディース デザイナーズバッグ Model #2', 'デイリーユースからフォーマルまで対応可能な2WAYレザートート。充実したインナーポケット付き。', 14500, 10, 'products/bag_lady/Image_fx (10).jpg', TRUE),
(3, 'レディース デザイナーズバッグ Model #3', '洗練されたミニマルフォルムが美しいクラシックショルダーバッグ。', 9800, 8, 'products/bag_lady/Image_fx (11).jpg', TRUE),
(4, 'エレガント ファッション小物 Model #1', '装いに気品を添えるシルクタッチスカーフ＆アクセサリーセット。', 4200, 20, 'products/fashion_etc_lady/Image_fx (1).jpg', TRUE),
(5, 'エレガント ファッション小物 Model #2', '繊細な細工が施されたプレミアムレザーウォレット。ギフトにも最適。', 6800, 12, 'products/fashion_etc_lady/Image_fx (10).jpg', TRUE),
(6, 'エレガント ファッション小物 Model #3', '上質な輝きを放つミニマムデザインブレスレット。', 3500, 18, 'products/fashion_etc_lady/Image_fx (11).jpg', TRUE),
(7, 'ベストセラー文芸小説 Model #1', '深い物語と感動が広がる注目の話題作。休日のリラックスタイムに。', 1800, 25, 'products/novel/Image_fx (1).jpg', TRUE),
(8, 'ベストセラー文芸小説 Model #2', '時代を超えて読み継がれる名著の特装版。装丁にもこだわり抜いた1冊。', 2200, 15, 'products/novel/Image_fx (10).jpg', TRUE),
(9, 'ベストセラー文芸小説 Model #3', '知的好奇心を刺激する現代文学のマスターピース。', 1600, 30, 'products/novel/Image_fx (11).jpg', TRUE),
(10, 'クラシック・ヴィンテージセレクション Model #1', '一点ものの味わい深いヴィンテージアイテム。時代を超えた風合いが魅力。', 18500, 5, 'products/old/Image_fx (1).jpg', TRUE),
(11, 'クラシック・ヴィンテージセレクション Model #2', '熟練の職人技が息づくアンティーク調レトロコレクション。', 24000, 3, 'products/old/Image_fx (10).jpg', TRUE),
(12, 'クラシック・ヴィンテージセレクション Model #3', 'コレクター必見の希少なヴィンテージプレミアムピース。', 15800, 4, 'products/old/Image_fx (11).jpg', TRUE),
(13, 'スタイリッシュ ワンピース Model #1', '優雅なドレープと美しいAラインシルエットを描くラグジュアリードレス。', 13800, 10, 'products/onepiece_lady/Image_fx (1).jpg', TRUE),
(14, 'スタイリッシュ ワンピース Model #2', 'パーティーからオケージョンまで映える上質サテンワンピース。', 16500, 8, 'products/onepiece_lady/Image_fx (10).jpg', TRUE),
(15, 'スタイリッシュ ワンピース Model #3', 'リラックスした着心地と気品を兼ね備えたカシュクールワンピース。', 11000, 14, 'products/onepiece_lady/Image_fx (11).jpg', TRUE),
(16, 'レディース トレンドアウター Model #1', '上質ウール混素材を採用した洗練のチェスターロングコート。', 28500, 6, 'products/outer_lady/Image_fx (1).jpg', TRUE),
(17, 'レディース トレンドアウター Model #2', '防寒性と軽やかな着心地を両立したラグジュアリーダウンジャケット。', 32000, 7, 'products/outer_lady/Image_fx (10).jpg', TRUE),
(18, 'レディース トレンドアウター Model #3', '羽織るだけでエレガントに決まるプレミアムトレンチコート。', 24800, 9, 'products/outer_lady/Image_fx (11).jpg', TRUE),
(19, 'メンズ カジュアルジャケット/コート Model #1', 'クラシカルなテーラリングが際立つメンズプレミアムブレザー。', 26000, 8, 'products/outer_men/Image_fx (1).jpg', TRUE),
(20, 'メンズ カジュアルジャケット/コート Model #2', '無骨さと上品さを兼備したミリタリーライクフィールドジャケット。', 22500, 11, 'products/outer_men/Image_fx (10).jpg', TRUE),
(21, 'メンズ カジュアルジャケット/コート Model #3', '上質なツイード生地が温かみと重厚感を与えるウールコート。', 29800, 5, 'products/outer_men/Image_fx (11).jpg', TRUE),
(22, 'メンズ テーラードパンツ/スラックス Model #1', '美しいセンタープレスと快適な履き心地のテーパードスラックス。', 8800, 16, 'products/pants_men/Image_fx (1).jpg', TRUE),
(23, 'メンズ テーラードパンツ/スラックス Model #2', 'ビジネスからオフスタイルまで万能に着こなせるスリムチノトラウザー。', 7900, 20, 'products/pants_men/Image_fx (10).jpg', TRUE),
(24, 'メンズ テーラードパンツ/スラックス Model #3', 'ストレッチ混の上質ウールライクファブリックを使用した快適パンツ。', 9500, 12, 'products/pants_men/Image_fx (11).jpg', TRUE),
(25, 'レディース コンフォートシューズ Model #1', '足元を華やかに彩るエレガントポインテッドトゥパンプス。', 14800, 10, 'products/shoes_lady/Image_fx (1).jpg', TRUE),
(26, 'レディース コンフォートシューズ Model #2', '履き心地を追求したクッションインソール入りクラシックローファー。', 12500, 15, 'products/shoes_lady/Image_fx (10).jpg', TRUE),
(27, 'レディース コンフォートシューズ Model #3', '上質なカーフレザーで仕立てた美しいレザーアンクルブーツ。', 19800, 8, 'products/shoes_lady/Image_fx (11).jpg', TRUE),
(28, 'フレア＆タイトスカート Model #1', '揺れるプリーツがドラマティックなロングフレアスカート。', 7800, 14, 'products/skirt_lady/Image_fx (1).jpg', TRUE),
(29, 'フレア＆タイトスカート Model #2', 'すっきりとした縦ラインでスタイルアップを叶えるタイトペンシルスカート。', 6900, 18, 'products/skirt_lady/Image_fx (10).jpg', TRUE),
(30, 'フレア＆タイトスカート Model #3', '季節感あふれる上品なチェック柄フレアスカート。', 8500, 12, 'products/skirt_lady/Image_fx (11).jpg', TRUE),
(31, 'レディース プレミアムトップス Model #1', '極上の肌触りを誇るハイゲージシルク混ニットプルオーバー。', 8900, 15, 'products/tops_lady/Image_fx (1).jpg', TRUE),
(32, 'レディース プレミアムトップス Model #2', '繊細なボウタイデザインがオフィスシーンにも映えるエレガントブラウス。', 7200, 20, 'products/tops_lady/Image_fx (10).jpg', TRUE),
(33, 'レディース プレミアムトップス Model #3', '一枚でこなれた雰囲気を演出する上質オーバーサイズリブニット。', 9800, 12, 'products/tops_lady/Image_fx (11).jpg', TRUE),
(34, 'メンズ クラシックシャツ/ニット Model #1', '高級エジプト超長綿を使用した艶感のあるドレスシャツ。', 7800, 18, 'products/tops_men/Image_fx (1).jpg', TRUE),
(35, 'メンズ クラシックシャツ/ニット Model #2', '上質メリノウール100%で編み上げたクルーネックセーター。', 9500, 14, 'products/tops_men/Image_fx (10).jpg', TRUE),
(36, 'メンズ クラシックシャツ/ニット Model #3', '羽織りとしても主役としても活躍する上質オックスフォードシャツ。', 6800, 22, 'products/tops_men/Image_fx (11).jpg', TRUE),
(37, '【画像準備中】限定コラボレーション パーカー', '次回入荷予定の新作コラボレーション限定アイテム。画像は準備中ですが先行予約受付中。', 12000, 5, NULL, TRUE),
(38, '【サンプル品】ハンドメイド レザーキーケース', '職人が手縫いで仕上げた一点物レザー小物。画像未登録のため特別価格にてご提供。', 2500, 8, NULL, TRUE);

-- 4. 商品タグ紐付け
INSERT INTO product_tags (product_id, tag_id) VALUES
(1, 1), (1, 3), (2, 1), (2, 3), (3, 1), (3, 3),
(4, 1), (4, 9), (5, 1), (5, 9), (6, 1), (6, 9),
(7, 10), (8, 10), (9, 10),
(10, 11), (11, 11), (12, 11),
(13, 1), (13, 5), (14, 1), (14, 5), (15, 1), (15, 5),
(16, 1), (16, 4), (17, 1), (17, 4), (18, 1), (18, 4),
(19, 2), (19, 4), (20, 2), (20, 4), (21, 2), (21, 4),
(22, 2), (23, 2), (24, 2),
(25, 1), (25, 6), (26, 1), (26, 6), (27, 1), (27, 6),
(28, 1), (28, 7), (29, 1), (29, 7), (30, 1), (30, 7),
(31, 1), (31, 8), (32, 1), (32, 8), (33, 1), (33, 8),
(34, 2), (34, 8), (35, 2), (35, 8), (36, 2), (36, 8),
(37, 2), (37, 8), (38, 9);

-- 5. テスト注文データ
INSERT INTO orders (id, user_id, order_number, full_name, postal_code, address, phone_number, email, payment_method, total_price, status) VALUES
(1, 2, 'ORD-SERVLET2026', '学生 太郎', '150-0002', '東京都渋谷区渋谷1-2-3 演習ビル5F', '090-9999-8888', 'student@example.com', 'credit_card', 27300, 'completed');

INSERT INTO order_items (order_id, product_id, product_name, price, quantity) VALUES
(1, 1, 'レディース デザイナーズバッグ Model #1', 12800, 1),
(1, 2, 'レディース デザイナーズバッグ Model #2', 14500, 1);

-- 6. テストお気に入りデータ
INSERT INTO favorites (user_id, product_id) VALUES
(2, 1), (2, 13), (2, 16), (2, 25);

-- シーケンスを最新IDに更新
SELECT setval('users_id_seq', (SELECT MAX(id) FROM users));
SELECT setval('tags_id_seq', (SELECT MAX(id) FROM tags));
SELECT setval('products_id_seq', (SELECT MAX(id) FROM products));
SELECT setval('orders_id_seq', (SELECT MAX(id) FROM orders));
SELECT setval('order_items_id_seq', (SELECT MAX(id) FROM order_items));
SELECT setval('favorites_id_seq', (SELECT MAX(id) FROM favorites));
