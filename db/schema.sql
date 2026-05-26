CREATE TABLE shops (
  id BIGSERIAL PRIMARY KEY,
  platform TEXT NOT NULL DEFAULT 'etsy',
  shop_name TEXT NOT NULL,
  etsy_shop_id TEXT,
  timezone TEXT NOT NULL DEFAULT 'UTC',
  status TEXT NOT NULL DEFAULT 'active',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE style_profiles (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  description TEXT,
  palette_json JSONB NOT NULL,
  negative_prompt TEXT,
  policy_level TEXT NOT NULL DEFAULT 'strict',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE themes (
  id BIGSERIAL PRIMARY KEY,
  category TEXT NOT NULL,
  keywords_json JSONB NOT NULL,
  seasonality_json JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE artworks (
  id BIGSERIAL PRIMARY KEY,
  shop_id BIGINT NOT NULL REFERENCES shops(id),
  style_profile_id BIGINT NOT NULL REFERENCES style_profiles(id),
  theme_id BIGINT REFERENCES themes(id),
  title_working TEXT,
  prompt_text TEXT NOT NULL,
  negative_prompt_text TEXT,
  model_name TEXT NOT NULL,
  seed BIGINT,
  status TEXT NOT NULL DEFAULT 'generated',
  ip_risk_score NUMERIC(5,2) NOT NULL DEFAULT 0,
  quality_score NUMERIC(5,2) NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE artwork_files (
  id BIGSERIAL PRIMARY KEY,
  artwork_id BIGINT NOT NULL REFERENCES artworks(id) ON DELETE CASCADE,
  file_type TEXT NOT NULL,
  path TEXT NOT NULL,
  width INT,
  height INT,
  dpi INT,
  checksum TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE qc_reports (
  id BIGSERIAL PRIMARY KEY,
  artwork_id BIGINT NOT NULL REFERENCES artworks(id) ON DELETE CASCADE,
  check_type TEXT NOT NULL,
  score NUMERIC(5,2) NOT NULL,
  result TEXT NOT NULL,
  details_json JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE listing_drafts (
  id BIGSERIAL PRIMARY KEY,
  artwork_id BIGINT NOT NULL REFERENCES artworks(id) ON DELETE CASCADE,
  platform TEXT NOT NULL DEFAULT 'etsy',
  etsy_listing_id TEXT,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  tags_json JSONB NOT NULL,
  materials_json JSONB,
  price NUMERIC(10,2) NOT NULL,
  currency TEXT NOT NULL DEFAULT 'USD',
  state TEXT NOT NULL DEFAULT 'draft',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE ab_tests (
  id BIGSERIAL PRIMARY KEY,
  listing_draft_id BIGINT NOT NULL REFERENCES listing_drafts(id) ON DELETE CASCADE,
  variant_type TEXT NOT NULL,
  variant_value JSONB NOT NULL,
  start_at TIMESTAMPTZ NOT NULL,
  end_at TIMESTAMPTZ,
  winner_flag BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE performance_daily (
  id BIGSERIAL PRIMARY KEY,
  listing_draft_id BIGINT NOT NULL REFERENCES listing_drafts(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  views INT NOT NULL DEFAULT 0,
  favorites INT NOT NULL DEFAULT 0,
  orders INT NOT NULL DEFAULT 0,
  revenue NUMERIC(10,2) NOT NULL DEFAULT 0,
  conversion_rate NUMERIC(6,4) NOT NULL DEFAULT 0,
  UNIQUE (listing_draft_id, date)
);

CREATE TABLE agent_runs (
  id BIGSERIAL PRIMARY KEY,
  agent_name TEXT NOT NULL,
  input_json JSONB,
  output_json JSONB,
  status TEXT NOT NULL,
  duration_ms INT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE policy_flags (
  id BIGSERIAL PRIMARY KEY,
  artwork_id BIGINT NOT NULL REFERENCES artworks(id) ON DELETE CASCADE,
  flag_type TEXT NOT NULL,
  severity TEXT NOT NULL,
  reason TEXT NOT NULL,
  resolved BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_artworks_status_created_at ON artworks(status, created_at DESC);
CREATE INDEX idx_listing_drafts_state_created_at ON listing_drafts(state, created_at DESC);
CREATE INDEX idx_performance_daily_date_revenue ON performance_daily(date, revenue DESC);
CREATE INDEX idx_policy_flags_severity_created_at ON policy_flags(severity, created_at DESC);
