# Webアプリケーション公開実践マニュアル（AWS EC2編）

このマニュアルでは、手元のパソコンで作ったWebアプリケーション（Django / Flask / Servlet）を、世界中のインターネットから誰でも見られるように「クラウドサーバー（AWS EC2）」へ設置して公開する手順を、ゼロから順番に解説します。

---

## 全体の流れ（何をするのか？）

私たちが普段使っているパソコンの電源を切ると、その中で動いているアプリも見られなくなってしまいます。
そこで、**24時間365日ずっとインターネットに繋がり続けている専用のコンピューター（AWS EC2サーバー）** を1台借りて、そこにプログラムを設置します。

```
[ あなたのパソコン ]
       │
       ▼ (1) プログラムをGitHubに送る (完了済み)
  [ GitHub ]
       │
       ▼ (2) サーバーがGitHubからプログラムをダウンロードする
[ AWS EC2 サーバー (インターネット上のコンピューター) ]
       │
       ├─ 受付係（Nginx）：インターネットからのアクセスを整理する
       ├─ アプリ本体（Django / Flask / Servlet）：画面や機能を動かす
       └─ データベース（PostgreSQL / SQLite）：データを安全に保管する
```

作業は以下の **5つのステップ** で進めます。

1. **AWSで自分専用のサーバー（EC2）を作成する**
2. **自分のパソコンからサーバーにログイン（遠隔操作）する**
3. **サーバーにプログラムと必要な道具を準備する**
4. **アプリをサーバー上で起動する（常駐化）**
5. **インターネットからのアクセスを受付係（Nginx）に繋ぐ**

---

## ステップ 1: AWSでサーバー（EC2）を作ろう

まずはAWS（Amazon Web Services）の中に、Linux（Ubuntu）というOSが入ったコンピューターを1台新しく立ち上げます。

### 1-1. AWSマネジメントコンソールにログインする
1. ブラウザでAWSにサインインします。
2. 画面右上の地域（リージョン）が **「東京（ap-northeast-1）」** になっていることを確認してください。（他の地域だと通信が少し遅くなります）

### 1-2. EC2の画面を開く
1. 画面上部の検索バーに `EC2` と入力し、表示された **「EC2」** をクリックします。
2. 左メニューの「インスタンス」をクリックし、オレンジ色の **「インスタンスを起動」** ボタンをクリックします。

### 1-3. サーバーの設定を決める
画面の指示に従って、上から順番に設定を入力・選択していきます。

| 項目名 | 設定する値 | 解説 |
| :--- | :--- | :--- |
| **名前とタグ** | `my-web-server` など自由 | サーバーの識別名です。わかりやすい名前をつけます。 |
| **アプリケーションおよび OS イメージ (AMI)** | **Ubuntu** を選択<br>（バージョン: **Ubuntu Server 24.04 LTS**） | サーバー用として世界中で最も広く使われている安定したLinuxです。 |
| **アーキテクチャ** | `64 ビット (x86)` | 標準のCPU形式です。 |
| **インスタンスタイプ** | **`t2.micro`** または **`t3.micro`** | 「無料利用枠の対象」と緑色で書かれているものを選びます。 |

### 1-4. キーペア（サーバーの鍵）を作る
サーバーにログインするための「秘密鍵」を作ります。**この鍵を紛失すると二度とサーバーに入れなくなるため大切に保管してください。**

1. **「キーペア (ログイン)」** の項目で、右側の **「新しいキーペアの作成」** をクリックします。
2. **キーペア名**: `my-key` など英数字で入力します。
3. **キーペアのタイプ**: `RSA` を選択します。
4. **プライベートキーファイル形式**:
   - WindowsのPowerShellやMacのターミナルを使う場合: **`.pem`** を選択
5. **「キーペアを作成」** をクリックすると、パソコンに `my-key.pem` というファイルがダウンロードされます。
   - ダウンロードしたファイルは、誤って削除しない安全な場所（例: `C:\Users\ユーザー名\.ssh\` やデスクトップの専用フォルダ）に保存しておきます。

### 1-5. ネットワーク設定（ファイアウォールの設定）
インターネットからサーバーへの「通信の通り道」を開けます。

1. **「ネットワーク設定」** の右側にある **「編集」** をクリックします。
2. **ファイアウォール (セキュリティグループ)** で **「セキュリティグループを作成」** を選択します。
3. 以下の **3つのルール** が入っていることを確認します。（足りない場合は「セキュリティグループルールの追加」をクリックして追加します）

| 種類 | ポート範囲 | ソース（接続元） | 役割 |
| :--- | :--- | :--- | :--- |
| **SSH** | `22` | **自分のIP**（推奨）または `任意の場所 (0.0.0.0/0)` | 自分のパソコンからサーバーを遠隔操作するための通り道 |
| **HTTP** | `80` | **任意の場所 (0.0.0.0/0)** | 世界中の人がWebブラウザでホームページを見るための通り道 |
| **HTTPS** | `443` | **任意の場所 (0.0.0.0/0)** | 暗号化された安全なWeb通信のための通り道 |

> [!WARNING]
> HTTP（ポート80）にチェックが入っていないと、あとでアプリを動かしてもブラウザからサイトを開くことができません。必ず「インターネットからの HTTP トラフィックを許可する」にチェックを入れてください。

### 1-6. 起動する
画面右下のオレンジ色の **「インスタンスを起動」** ボタンをクリックします。
約1〜2分待つと、インスタンス一覧画面でステータスが **「実行中」** に変わります。

---

## ステップ 2: 自分のパソコンからサーバーに遠隔ログインしよう

手元のパソコンから黒い画面（ターミナル）を使って、クラウド上のサーバーに「SSH」という仕組みで遠隔接続します。

### 2-1. サーバーの「IPアドレス」を調べる
1. EC2の「インスタンス」画面で、作成したサーバーをクリックして選択します。
2. 画面下部に表示される情報の中から **「パブリック IPv4 アドレス」**（例: `54.238.123.45` のような4つの数字の組み合わせ）を見つけてコピーします。

### 2-2. ターミナルから接続する
手元のパソコンで **PowerShell**（Windows）または **ターミナル**（Mac）を開きます。

1. ダウンロードした鍵ファイル（`.pem`）がある場所に移動します。
   （例: ダウンロードフォルダにある場合）
   ```powershell
   cd C:\Users\admin\Downloads
   ```

2. 鍵を使って以下のコマンドでサーバーにログインします：
   （※ `my-key.pem` はご自身の鍵ファイル名、`54.238.123.45` は先ほどコピーした自分のパブリックIPv4アドレスに置き換えてください）
   ```powershell
   ssh -i my-key.pem ubuntu@54.238.123.45
   ```

3. 初回接続時、英語で「本当に接続しますか？ (yes/no/[fingerprint])」と聞かれます。
   キーボードで **`yes`** と入力して Enter を押します。

4. 画面の左側の表示が `ubuntu@ip-172-31-xx-xx:~$` のように変われば、**サーバーへの遠隔ログイン成功** です！
   ここからの作業は、すべてこのサーバーの中で実行します。

---

## ステップ 3: サーバーに必要な道具を入れよう

生まれたてのサーバーには、PythonもJavaもデータベースも入っていません。アプリを動かすための道具を一括でインストールします。

### 3-1. サーバーを最新の状態に更新する
サーバーの中身を最新情報に更新します。以下のコマンドを1行ずつコピーして貼り付け、Enter を押してください。

```bash
sudo apt update && sudo apt upgrade -y
```
> **コマンドの意味**:
> `sudo` は「管理者権限で実行する」、`apt` はUbuntuの「アプリストア（パッケージ管理）」です。スマートフォンでいう「OSのアップデート」を行っています。

### 3-2. 必要なソフトウェアをまとめてインストールする
Webサーバー（Nginx）、Python、Java、PostgreSQL、Git をインストールします。

```bash
sudo apt install -y python3-pip python3-venv openjdk-17-jdk tomcat10 postgresql postgresql-contrib nginx git
```
（※処理が終わるまで1〜2分かかります。プロンプト `ubuntu@...:$` に戻るまでお待ちください）

### 3-3. GitHubからプログラムをダウンロードする
サーバー上にWebプログラムを置くための専用フォルダ（`/var/www`）を作り、GitHubからプログラムをまるごとクローン（複製）します。

```bash
cd /var/www
sudo git clone https://github.com/th-kairi/91_SampleProgram.git exshop
sudo chown -R ubuntu:ubuntu /var/www/exshop
```
> **コマンドの意味**:
> `cd /var/www` でWeb用の保管場所に移動し、`git clone` でGitHubから最新プログラムをダウンロードしています。
> 最後の `chown` は、ダウンロードしたファイルの操作権限をログイン中の `ubuntu` ユーザーに渡す命令です。

これで `/var/www/exshop` の中に、以下の3つのアプリが配置されました：
- `01_Django` （Django版 ストリート系ECサイト）
- `02_Flask` （Flask版 北欧ナチュラル系ECサイト）
- `03_Servlet` （Servlet/JSP版 ラグジュアリー系ECサイト）

---

## ステップ 4: アプリケーションを動かそう（エディション別）

動かしたいエディションの手順を選んで進めてください。もちろん、ポート（窓口番号）が分かれているため、**3つすべてを同時に動かすことも可能** です。

---

### コース A: Django版を動かす（ポート 8000）

Djangoは、Pythonの専用の部屋（仮想環境 `venv`）を作って動かします。

#### 1. フォルダに移動して仮想環境を作る
```bash
cd /var/www/exshop/01_Django
python3 -m venv venv
source venv/bin/activate
```
（※プロンプトの先頭に `(venv)` と表示されれば仮想環境に入れています）

#### 2. 必要なライブラリを入れる
```bash
pip install -r requirements.txt gunicorn
```

#### 3. データベースの準備と画像の整理
```bash
python manage.py migrate
python manage.py collectstatic --noinput
```

#### 4. 24時間止まらないようにバックグラウンドで動かす（systemd）
ターミナルを閉じてもアプリが動き続けるように、Ubuntuの「常駐サービス」として登録します。以下のコマンドをそのまま貼り付けて Enter を押します。

```bash
sudo bash -c 'cat <<EOF > /etc/systemd/system/django_exshop.service
[Unit]
Description=Gunicorn instance for Django exShop
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/var/www/exshop/01_Django
Environment="PATH=/var/www/exshop/01_Django/venv/bin"
ExecStart=/var/www/exshop/01_Django/venv/bin/gunicorn --workers 3 --bind 127.0.0.1:8000 exShop.wsgi:application

[Install]
WantedBy=multi-user.target
EOF'
```

サービスを起動します：
```bash
sudo systemctl daemon-reload
sudo systemctl enable --now django_exshop
```

状態を確認します：
```bash
sudo systemctl status django_exshop
```
緑色で `active (running)` と表示されていれば、Djangoがサーバー内部（ポート8000）で正常に動き続けています！（確認が終わったらキーボードの `q` を押して元の画面に戻ります）

---

### コース B: Flask版を動かす（ポート 5000）

#### 1. フォルダに移動して仮想環境を作る
```bash
cd /var/www/exshop/02_Flask
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt gunicorn
```

#### 2. 常駐サービスとして登録する
```bash
sudo bash -c 'cat <<EOF > /etc/systemd/system/flask_exshop.service
[Unit]
Description=Gunicorn instance for Flask exShop Nordic
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/var/www/exshop/02_Flask
Environment="PATH=/var/www/exshop/02_Flask/venv/bin"
ExecStart=/var/www/exshop/02_Flask/venv/bin/gunicorn --workers 3 --bind 127.0.0.1:5000 run:app

[Install]
WantedBy=multi-user.target
EOF'
```

サービスを起動します：
```bash
sudo systemctl daemon-reload
sudo systemctl enable --now flask_exshop
```

状態を確認します：
```bash
sudo systemctl status flask_exshop
```
緑色で `active (running)` と表示されていれば成功です！（キーボードの `q` で戻ります）

---

### コース C: Servlet / JSP版を動かす（Tomcat 10 + PostgreSQL）

ServletはJava専用のWebコンテナ「Tomcat 10」と、本格的なリレーショナルデータベース「PostgreSQL」を使って動かします。

#### 1. PostgreSQLにデータベースとユーザーを作る
データベースの管理者（postgres）としてログインし、専用のユーザーとデータベースを作成します。

```bash
sudo -u postgres psql -c "CREATE USER exshop WITH PASSWORD 'exshop_pass';"
sudo -u postgres psql -c "CREATE DATABASE exshop_db OWNER exshop;"
```

初期テーブルとサンプル商品データを流し込みます：
```bash
cd /var/www/exshop/03_Servlet
PGPASSWORD='exshop_pass' psql -U exshop -d exshop_db -h localhost -f sql/schema.sql
PGPASSWORD='exshop_pass' psql -U exshop -d exshop_db -h localhost -f sql/data.sql
```

#### 2. WARファイルをTomcatに配置する
JavaのWebアプリは、すべての部品がひとつに圧縮された「WARファイル」としてTomcatに渡すだけで動きます。

```bash
# プログラムをビルドしてWARファイルを作成（すでにtargetにある場合はコピーでOK）
cd /var/www/exshop/03_Servlet
sudo cp target/exShop.war /var/lib/tomcat10/webapps/ROOT.war
sudo systemctl restart tomcat10
```
> **ポイント**: `ROOT.war` という名前にして配置することで、URLの末尾に余計なパスを付けずにトップページとして表示できるようになります。

状態を確認します：
```bash
sudo systemctl status tomcat10
```
緑色で `active (running)` となっていれば成功です！（`q` で戻ります）

---

## ステップ 5: 受付係（Nginx）を設定して世界に公開しよう！

現在、各アプリはサーバーの内部（8000番や5000番、8080番）で元気に動いていますが、外部のインターネットからはセキュリティのため直接これらのポートには入れません。
そこで、**Webの標準窓口である「80番ポート（HTTP）」でアクセスを受け取り、それぞれのアプリへ案内する受付係（Nginx）** を設定します。

```
[ インターネット (ブラウザ) ]
           │
           ▼ ポート 80 でアクセス
     [ Nginx（受付係） ]
    ┌──────┼──────┐
    │      │      └─ URLが「/servlet/」なら ──▶ Tomcat (Port 8080)
    │      └──────── URLが「/flask/」なら ───▶ Flask (Port 5000)
    └─────────────── 通常のアクセス ─────────▶ Django (Port 8000)
```

### 5-1. Nginxの設定ファイルを書き換える
以下のコマンドをまるごと貼り付けて Enter を押します。Nginxに「どのURLに来たら、どのアプリに案内するか」の地図を登録します。

```bash
sudo bash -c 'cat <<EOF > /etc/nginx/sites-available/default
server {
    listen 80 default_server;
    server_name _;

    # Djangoの画像・CSSファイルを直接高速配信する設定
    location /static/ {
        alias /var/www/exshop/01_Django/static/;
    }
    location /media/ {
        alias /var/www/exshop/01_Django/media/;
    }

    # 通常アクセス (/) は Django へ案内
    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }

    # 「/flask/」で始まるアクセスは Flask へ案内
    location /flask/ {
        proxy_pass http://127.0.0.1:5000/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }

    # 「/servlet/」で始まるアクセスは Tomcat (Servlet) へ案内
    location /servlet/ {
        proxy_pass http://127.0.0.1:8080/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF'
```

### 5-2. 設定をテストしてNginxを再起動する
設定ファイルに誤字や文法エラーがないかチェックします：
```bash
sudo nginx -t
```
画面に `syntax is ok` および `test is successful` と出れば完璧です！

Nginxを再起動して新しい設定を反映します：
```bash
sudo systemctl restart nginx
```

---

## ステップ 6: ブラウザで実際に見てみよう！

おめでとうございます！これでインターネットへの公開作業はすべて完了です。
手元のパソコンやスマートフォンのブラウザを開いて、以下のURLにアクセスしてみましょう。

* **Django版（ストリート系デザイン）を見たいとき**:
  `http://<あなたのEC2のパブリックIP>/`
  （例: `http://54.238.123.45/`）

* **Flask版（北欧ナチュラル系デザイン）を見たいとき**:
  `http://<あなたのEC2のパブリックIP>/flask/`
  （例: `http://54.238.123.45/flask/`）

* **Servlet版（ラグジュアリー・シック系デザイン）を見たいとき**:
  `http://<あなたのEC2のパブリックIP>/servlet/`
  （例: `http://54.238.123.45/servlet/`）

スマートフォンからでも、友人のパソコンからでも、URLを入力すれば自分が立ち上げた本格ECサイトが世界中どこからでも閲覧・注文できます！

---

## 困ったときのトラブルシューティング

### Q1. ブラウザで開いても「応答時間が長すぎます」「接続できません」となる
* **原因**: AWSのセキュリティグループで、HTTP（ポート80）の通信がブロックされています。
* **解決策**: AWSマネジメントコンソールの「EC2」→「セキュリティグループ」を開き、「インバウンドルール」に「HTTP / ポート80 / 0.0.0.0/0」が許可されているか確認してください。

### Q2. 「502 Bad Gateway」というエラー画面が出る
* **原因**: 受付係のNginxは動いていますが、その奥にいるアプリ（DjangoやFlask）が起動していません。
* **解決策**: サーバーのターミナルで `sudo systemctl status django_exshop` または `sudo systemctl status flask_exshop` を実行し、赤文字でエラーが出ていないか確認してください。停止している場合は `sudo systemctl restart django_exshop` を試します。

### Q3. サイトは開くが、画像やデザイン（CSS）が崩れて文字だけになる
* **原因**: 画像やCSSファイルの場所が正しく読み込めていません。
* **解決策**: Djangoの場合は `cd /var/www/exshop/01_Django && python manage.py collectstatic --noinput` を再度実行し、ファイルのアクセス権限（`sudo chown -R ubuntu:ubuntu /var/www/exshop`）を与え直してください。
