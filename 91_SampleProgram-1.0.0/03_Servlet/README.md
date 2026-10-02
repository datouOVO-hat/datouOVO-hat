# exShop - Luxury Collection (Java Servlet / JSP 版)

Jakarta EE 10 (Servlet 6.0 / JSP 3.1) および PostgreSQL を使用した、本格的なエンタープライズECサイト演習プログラムです。

Django版と同等の全機能（商品一覧、検索、タグ絞り込み、詳細、カート、購入処理、履歴、お気に入り、出品登録、画像フォールバック）を実装しつつ、**「CommonServlet 継承型フロントコントローラ」** と **「ネイビー × ゴールドのラグジュアリーデザイン」** を採用しています。

---

## 1. アーキテクチャ設計

### ① フロントコントローラ設計 (`CommonServlet` 継承モデル)
- すべてのサーブレットは `HttpServlet` を直接継承せず、基底クラス `com.exshop.servlet.CommonServlet` を継承します。
- `CommonServlet` が以下の共通処理を一括制御します：
  - 文字エンコーディングの自動設定 (`UTF-8`)
  - 全ページ共通データの自動リクエスト注入（全タグ一覧、セッションカート、お気に入りIDセット）
  - フラッシュメッセージの転送ハンドリング
  - 共通遷移メソッド（`forward(req, resp, jspPath)`, `redirect(resp, path)`）
  - 未ログイン時の自動リダイレクト制御 (`requireLogin`)
  - 共通エラーハンドリング (`error.jsp`)

### ② データアクセス設計 (DAO & Bean パターン)
- **JavaBeans**: `ProductBean`, `TagBean`, `UserBean`, `OrderBean`, `OrderItemBean`, `FavoriteBean`, `CartBean`
- **DAO**: `ProductDAO`, `TagDAO`, `UserDAO`, `OrderDAO`, `FavoriteDAO`
- **トランザクション管理**: `OrderDAO` にて `Connection.setAutoCommit(false)` を使用し、注文確定・明細登録・在庫減算を不可分に実行。
- **コネクションプール**: `HikariCP` を採用し、高負荷環境・本番運用に耐えうる接続管理を実現。

---

## 2. データベースのセットアップ (PostgreSQL)

### ① データベースの作成
PostgreSQL（psql または pgAdmin / DBeaver）でデータベースを作成します：
```sql
CREATE DATABASE exshop_db WITH ENCODING 'UTF8';
```

### ② テーブル作成と初期データ投入
プロジェクトの `sql/` ディレクトリ配下の SQL を順番に実行します：
```bash
# 1. テーブル作成
psql -U postgres -d exshop_db -f sql/schema.sql

# 2. 初期データ (タグ11件、商品38件、ユーザー等) 投入
psql -U postgres -d exshop_db -f sql/data.sql
```

### ③ 接続設定 (`src/main/resources/db.properties`)
必要に応じて接続先ユーザー・パスワードを変更してください：
```properties
db.url=jdbc:postgresql://localhost:5432/exshop_db
db.user=postgres
db.password=postgres
```
※ AWS等のクラウド環境では、環境変数 `JDBC_DATABASE_URL`, `JDBC_DATABASE_USERNAME`, `JDBC_DATABASE_PASSWORD` を設定することで、ソースコードを変更せずに外部RDSへ自動接続できます。

---

## 3. 初期アカウント情報

| アカウント種別 | ユーザー名 | パスワード | 用途 |
|---|---|---|---|
| **管理者 (Admin)** | `admin` | `admin123` | 商品出品・登録、注文管理 |
| **学生 (Student)** | `student` | `student123` | 一般購入者テスト、履歴・お気に入り確認 |

---

## 4. WARファイルの作成 (ビルド)

Maven を使用して `.war` ファイルを生成します：

```bash
# プロジェクトディレクトリで実行
mvn clean package
```
ビルドが完了すると、`target/exShop.war` が生成されます。

---

## 5. Eclipse での開発・実行手順

1. Eclipse を起動し、メニューから **「ファイル (File)」→「インポート (Import)」** を選択。
2. **「Maven」→「既存の Maven プロジェクト (Existing Maven Projects)」** を選択し、「次へ」。
3. ルート・ディレクトリーに `03_Servlet` を指定し、「完了」。
4. プロジェクトを右クリック → **「実行 (Run As)」→「サーバーで実行 (Run on Server)」** で Tomcat 10 を選択して実行。
5. ブラウザで `http://localhost:8080/exShop/` にアクセス。

---

## 6. AWS EC2 (Tomcat 10) へのリリース演習手順

1. **EC2 サーバーの準備**:
   Ubuntu 22.04 / Amazon Linux 2023 に OpenJDK 17/21 と Tomcat 10 をインストール。
   ```bash
   sudo apt update && sudo apt install -y openjdk-17-jdk tomcat10 postgresql-client
   ```
2. **RDS PostgreSQL の作成**:
   AWS RDS で PostgreSQL インスタンスを作成し、`schema.sql` と `data.sql` を流し込む。
3. **WAR の配置**:
   生成した `target/exShop.war` を Tomcat の `webapps` ディレクトリに配置：
   ```bash
   sudo cp target/exShop.war /var/lib/tomcat10/webapps/ROOT.war
   ```
4. **環境変数の指定**:
   `/etc/environment` または Tomcat の `setenv.sh` に `JDBC_DATABASE_URL` を指定して Tomcat を再起動：
   ```bash
   sudo systemctl restart tomcat10
   ```
