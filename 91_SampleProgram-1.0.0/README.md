# exShop Multi-Framework EC Site Educational Program

本リポジトリは、同一のECサイト機能要件をもとに、3つの異なるWebテクノロジースタック（**Django** / **Flask** / **Servlet & JSP**）で実装された教育・演習用サンプルプログラム群です。

すべて共通の画像アセットおよび機能要件を持ちながら、フレームワークの思想やアーキテクチャ、そしてデザインテーマを明確に差別化して構築されています。

---

## 1. エディション一覧

| フォルダ | フレームワーク | データベース | デザインテーマ | 配布・成果物形式 |
|---|---|---|---|---|
| [01_Django](./01_Django) | **Django 5.2** | SQLite | ストリート・アパレル系 (Dark & Yellow) | `exShop_project.zip` |
| [02_Flask](./02_Flask) | **Flask 3.1** | SQLite / PostgreSQL | 北欧ナチュラル・ミニマル (Green & Wood) | `exShop_flask.zip` |
| [03_Servlet](./03_Servlet) | **Jakarta Servlet 6.0 / JSP** | **PostgreSQL** | ラグジュアリー・シック (Navy & Gold) | **`exShop.war`** |

---

## 2. 全エディション共通の実装機能

1. **ユーザー認証**: 新規登録、ログイン、ログアウト、マイページ
2. **管理者機能**: 商品登録・出品、情報編集、注文管理
3. **商品一覧・検索**: キーワード検索、タグ絞り込み、ソート（新着/価格）、ページネーション
4. **商品詳細**: 画像表示、関連商品レコメンド、在庫表示、お気に入り、カート追加
5. **画像フォールバック**: 未登録または欠損時は `no-image.png` を自動フォールバック表示
6. **カート機能**: セッションベースの数量変更・削除・小計/合計自動計算
7. **購入・注文処理**: 配送先入力、トランザクションによる注文保存、在庫連動
8. **購入履歴**: 会員専用の注文一覧および注文明細確認
9. **ウィッシュリスト**: ワンクリックでのお気に入り追加・解除、一覧閲覧

---

## 3. GitHub Releases による配布手順

GitHub の **Releases** 機能を活用して、パッケージを一括展開する手順です：

### Step 1: Git リポジトリの初期化とプッシュ
```bash
git init
git add .
git commit -m "feat: initial commit with Django, Flask, and Servlet editions"
git remote add origin <GitHubリポジトリURL>
git push -u origin main
```

### Step 2: タグの作成とプッシュ
```bash
git tag -a v1.0.0 -m "Release v1.0.0: exShop Multi-Framework Suite"
git push origin v1.0.0
```

### Step 3: GitHub Web画面での Release 作成
1. GitHub リポジトリ画面の右側 **「Releases」→「Create a new release」** をクリック。
2. Choose a tag で `v1.0.0` を選択。
3. Release title: `exShop v1.0.0 - Web開発・クラウド演習パッケージ`
4. **「Attach binaries by dropping them here or selecting them」** に以下のアセットをドラッグ＆ドロップ：
   - `01_Django/exShop_project.zip` (Django版演習コード)
   - `02_Flask/exShop_flask.zip` (Flask版演習コード)
   - `03_Servlet/target/exShop.war` (Servlet版WARパッケージ)
5. **「Publish release」** をクリックして公開！

Release ページから必要な ZIP / WAR をダウンロードするだけで、すぐに演習を開始できます。
