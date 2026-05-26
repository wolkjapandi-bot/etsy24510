# 実装タスク分解（Issue形式）

## EPIC-1: 基盤構築
### ISSUE-1: プロジェクト初期化
- **目的**: API/Worker/DBマイグレーションの土台を作る
- **完了条件**:
  - `api/` `workers/` `db/` `docs/` を作成
  - `.env.example` に必要な環境変数を定義
  - ヘルスチェックAPIを実装
- **受け入れ基準**:
  - `/health` が `200` を返す

### ISSUE-2: 認証・シークレット管理
- **目的**: Etsy OAuthトークンとAPIキーを安全に管理
- **完了条件**:
  - KMS/Secrets Manager連携
  - トークンの保存・更新API実装
- **受け入れ基準**:
  - 平文でトークンをDB保存しない

## EPIC-2: データモデル
### ISSUE-3: PostgreSQLスキーマ実装
- **目的**: 作品生成〜出品〜KPI収集までの一貫データ管理
- **完了条件**:
  - `db/schema.sql` のDDLを適用
  - 主要インデックスを作成
- **受け入れ基準**:
  - 初期マイグレーションが成功

## EPIC-3: 生成・QCパイプライン
### ISSUE-4: 生成ジョブ実装
- **目的**: スタイルプロファイルに基づく作品生成
- **完了条件**:
  - `generate_artwork_job` の実装
  - 画像メタ情報保存
- **受け入れ基準**:
  - 1ジョブで複数比率の成果物を生成

### ISSUE-5: QCゲート実装
- **目的**: 品質/規約リスクで自動判定
- **完了条件**:
  - `qc_gate_job` 実装
  - `qc_reports` と `policy_flags` 書き込み
- **受け入れ基準**:
  - 不合格作品が出品フローに進まない

## EPIC-4: Etsy出品自動化
### ISSUE-6: ドラフト作成API連携
- **目的**: Etsyにドラフトを自動作成
- **完了条件**:
  - `create_etsy_draft_job` 実装
  - タイトル/タグ/説明文登録
- **受け入れ基準**:
  - Etsy listing ID が `listing_drafts` に保存

### ISSUE-7: 画像・デジタルファイルアップロード
- **目的**: 作品画像とZIP/PDFを自動添付
- **完了条件**:
  - `upload_images_job`
  - `upload_digital_files_job`
- **受け入れ基準**:
  - Etsyドラフトからダウンロードファイル確認可能

### ISSUE-8: Human-in-the-loop 公開
- **目的**: 最終承認後のみ公開
- **完了条件**:
  - `human_approval_job` + `publish_listing_job`
- **受け入れ基準**:
  - 承認なし公開が不可能

## EPIC-5: 収益最適化
### ISSUE-9: KPI同期
- **目的**: 日次売上/閲覧/CVRの取り込み
- **完了条件**:
  - `sync_metrics_job` 実装
  - `performance_daily` へ保存
- **受け入れ基準**:
  - 過去30日KPIが取得できる

### ISSUE-10: ABテスト運用
- **目的**: タイトル・価格・サムネの継続改善
- **完了条件**:
  - `ab_tests` 運用API
  - 勝者の自動反映ロジック
- **受け入れ基準**:
  - stop/sustain/scale 判定が可能
