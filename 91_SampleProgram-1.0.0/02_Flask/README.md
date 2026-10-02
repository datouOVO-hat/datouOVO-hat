# exShop Nordic Edition (Python Flask 版)

Pythonの軽量フレームワーク「Flask」を使用した、北欧ナチュラル・ミニマルデザインのECサイト演習プログラムです。

---

## 1. 起動手順

```bash
# 仮想環境を作成＆有効化
python -m venv venv
.\venv\Scripts\activate  # Windows

# 依存ライブラリのインストール
pip install -r requirements.txt

# 初期データの投入 (商品38件、タグ、管理者/学生アカウント)
python seed.py

# 開発サーバーの起動 (ポート 5000)
python run.py
```
ブラウザで `http://127.0.0.1:5000/` にアクセスしてください。

## 2. アカウント情報
- 管理者: `admin` / `admin123`
- 学生: `student` / `student123`
