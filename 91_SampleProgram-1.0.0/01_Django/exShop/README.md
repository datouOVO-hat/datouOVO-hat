# exShop - セレクトECサイト演習プログラム (Django)

クラウド（AWS等）へのリリース演習およびWebアプリケーション開発の学習を目的とした、Django製ECサイトのサンプルプロジェクトです。

---

## 1. プロジェクト概要

- **フレームワーク**: Django 5.2 (Python 3.10+)
- **フロントエンド**: Bootstrap 5.3 + Bootstrap Icons
- **データベース**: SQLite (AWS本番環境では RDS PostgreSQL / MySQL に切り替え可能)
- **主要機能**:
  - 会員登録・ログイン・ログアウト・マイページ
  - 管理者機能（Django管理サイト `/admin/`、Web画面からの商品登録・編集）
  - 商品一覧・キーワード検索（名前・説明文）・ソート機能
  - タグによる商品絞り込み（レディース、メンズ、バッグ、アウター、ヴィンテージ等）
  - 商品詳細表示・関連商品レコメンド
  - カート機能（数量変更、削除、合計金額自動計算）
  - ご注文・購入手続き（配送先入力、注文確定、在庫連動）
  - ご購入履歴・注文明細確認
  - お気に入り機能（ワンクリックでの追加・解除、お気に入り一覧）
  - 未登録画像時の `no-image.png` フォールバック機能

---

## 2. 初期アカウント情報

初期データ投入スクリプト（`load_sample_data`）実行により、以下の検証用アカウントが作成されます。

| ユーザー種別 | ユーザー名 | パスワード | 用途 |
|---|---|---|---|
| **管理者 (Admin)** | `admin` | `admin123` | Django管理画面 (`/admin/`)、商品管理・編集 |
| **演習用学生** | `student` | `student123` | 一般購入者、購入履歴、お気に入り確認 |

※ 新規会員登録画面 (`/signup/`) から自由にお客様アカウントを作成することも可能です。

---

## 3. ローカル環境での起動手順

### ① 仮想環境の作成とライブラリのインストール
```bash
# 仮想環境を作成
python -m venv venv

# 仮想環境を有効化 (Windows PowerShell)
.\venv\Scripts\Activate.ps1
# ※ macOS / Linux の場合: source venv/bin/activate

# 依存ライブラリのインストール
pip install -r requirements.txt
```

### ② データベースのセットアップとサンプルデータ投入
```bash
# マイグレーション実行
python manage.py migrate

# 初期データ（商品38件、タグ、画像、管理者/学生アカウント）を一括投入
python manage.py load_sample_data
```

### ③ 開発サーバーの起動
```bash
python manage.py runserver
```
ブラウザで `http://127.0.0.1:8000/` にアクセスしてください。

---

## 4. AWSへのデプロイ演習手順（例: Amazon EC2 Linux環境）

### Step 1: EC2インスタンスの準備
1. Ubuntu 22.04 または Amazon Linux 2023 インスタンスを起動
2. セキュリティグループで **HTTP (ポート80)**, **SSH (ポート22)** を開放

### Step 2: サーバー環境のセットアップ
```bash
sudo apt update && sudo apt install -y python3-pip python3-venv nginx git
git clone <リポジトリURL> /var/www/exShop
cd /var/www/exShop

python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# 静的ファイルの収集
python manage.py collectstatic --noinput

# データベース初期化
python manage.py migrate
python manage.py load_sample_data
```

### Step 3: Gunicorn & Nginx の連携
`gunicorn --bind 127.0.0.1:8000 exShop.wsgi:application` を systemd サービスとして登録し、Nginx からリバースプロキシすることで本番公開できます。

---

## 5. ディレクトリ構成
```text
exShop/
├── exShop/               # プロジェクト設定 (settings.py, urls.py, wsgi.py)
├── shop/                 # ECサイトアプリ本体
│   ├── management/commands/  # load_sample_data コマンド
│   ├── models.py         # Tag, Product, Order, OrderItem, Favorite
│   ├── views.py          # ビューロジック
│   ├── forms.py          # 登録・注文フォーム
│   ├── cart.py           # カート管理クラス
│   ├── context_processors.py # 共通コンテキスト
│   └── urls.py           # アプリ内ルーティング
├── media/                # 商品画像 (products/ 及び no-image.png)
├── static/               # CSS, JS, カスタムスタイル
├── templates/            # HTMLテンプレート (Bootstrap 5)
├── requirements.txt      # 依存ライブラリ一覧
└── manage.py
```
