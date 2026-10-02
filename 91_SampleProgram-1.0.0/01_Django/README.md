# Django サンプルプログラム演習ワークスペース

本ディレクトリは、共通の Python 仮想環境（`venv`）を共有しながら、複数の Django プロジェクトを並行して作成・管理・学習するためのワークスペースです。

---

## 1. ワークスペース構造

```text
01_Django/                         # ワークスペースルート
├── venv/                          # 全プロジェクト共通の仮想環境
├── requirements.txt               # 共通依存ライブラリ一覧
├── media画像/                     # 元画像リソース
├── exShop_project.zip             # 学生配布用ZIPアーカイブ
│
├── exShop/                        # プロジェクト1: ECサイト演習プロジェクト
│   ├── manage.py
│   ├── db.sqlite3
│   ├── exShop/                    # 設定 (settings.py, urls.py, wsgi.py)
│   ├── shop/                      # ECアプリ (models, views, cart, admin)
│   ├── templates/                 # Bootstrap5 画面テンプレート
│   ├── static/                    # CSS, JS
│   ├── media/                     # コピー済み商品画像 & no-image.png
│   ├── README.md                  # exShop の詳細仕様 & AWSデプロイ手順
│   └── SPEC_EC_SITE.md            # AIプロンプト用仕様書 (Flask/Servlet展開用)
│
└── (今後作成する別プロジェクト)/     # 例: blogApp/, apiServer/ ...
```

---

## 2. 既存プロジェクト（exShop）の起動方法

仮想環境を有効化して、プロジェクトフォルダ内で実行します。

### Windows PowerShell の場合:
```powershell
# 1. 仮想環境を有効化
.\venv\Scripts\Activate.ps1

# 2. プロジェクトディレクトリへ移動
cd exShop

# 3. 開発サーバーを起動
python manage.py runserver
```

> **Note**: 仮想環境を有効化せずに直接実行する場合は以下でも起動可能です：
> ```powershell
> cd exShop
> ..\venv\Scripts\python.exe manage.py runserver
> ```

ブラウザで `http://127.0.0.1:8000/` にアクセスしてください。

### 初期アカウント（exShop）
- **管理者**: `admin` / `admin123`
- **一般学生**: `student` / `student123`

---

## 3. この環境で新しいDjangoプロジェクトを追加する場合の手順

同じ `venv` を流用して新しいプロジェクト（例: `myProject`）を作成する際は、ルートディレクトリ（`01_Django`）で次のようにコマンドを実行します：

```powershell
# 仮想環境の django-admin を呼び出して新規プロジェクトを作成
.\venv\Scripts\django-admin.exe startproject myProject

# 作成したプロジェクトへ移動してアプリ作成やマイグレーションを実行
cd myProject
..\venv\Scripts\python.exe manage.py startapp myApp
..\venv\Scripts\python.exe manage.py migrate
..\venv\Scripts\python.exe manage.py runserver
```
