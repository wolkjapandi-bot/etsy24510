# 60作品の自動生成 + Google Drive保存手順

## 1) 事前準備
1. Google CloudでService Accountを作成し、JSONキーを取得
2. 保存先Google Driveフォルダを作成し、Service Accountのメールアドレスに編集権限を付与
3. `.env.example` をコピーして `.env` を作成

## 2) 実行
```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
set -a; source .env; set +a
python scripts/generate_and_upload_60.py
```

## 3) 出力
- ローカル画像: `generated/poster_01.png` ... `generated/poster_60.png`
- 実行ログ/リンク: `generated/manifest.json`

## 注意
- API利用料金が発生します。
- 実在ブランド名・ロゴ・特定作家名の模倣は避けてください。
