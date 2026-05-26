# 公開ページの使い方

## 追加したページ
- `web/index.html`

## ローカルで確認
```bash
python -m http.server 8080
```

ブラウザで下記を開きます。
- `http://localhost:8080/web/`

## 公開方法の例
- GitHub Pages: `web/` を公開ディレクトリとして設定
- Cloudflare Pages / Netlify / Vercel: 静的サイトとしてデプロイ

## ギャラリー表示データ
- `generated/manifest.json` を読み込んでカード一覧を表示します。
- 生成スクリプト（`scripts/generate_and_upload_60.py`）実行後に `generated/manifest.json` が作成されます。
