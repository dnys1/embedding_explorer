import '../../../database/migration.dart';

Migration get migration {
  return Migration.fromStrings(
    version: 1,
    up: '''
-- Create data source configurations table
CREATE TABLE IF NOT EXISTS data_sources (
    id TEXT PRIMARY KEY NOT NULL,
    name TEXT NOT NULL,
    description TEXT NOT NULL DEFAULT '',
    type TEXT NOT NULL, -- csv, json, database, api, etc.
    filename TEXT NOT NULL, -- Filename of the data source
    settings TEXT NOT NULL, -- JSON string containing DataSourceSettings
    created_at TEXT NOT NULL, -- ISO 8601 datetime
    updated_at TEXT NOT NULL  -- ISO 8601 datetime
);

-- Create embedding template configurations table
CREATE TABLE IF NOT EXISTS templates (
    id TEXT PRIMARY KEY NOT NULL,
    name TEXT NOT NULL,
    description TEXT NOT NULL DEFAULT '',
    template TEXT NOT NULL,
    data_source_id TEXT NOT NULL,
    available_fields TEXT NOT NULL, -- JSON array of field names
    metadata TEXT NOT NULL DEFAULT '{}', -- JSON object for additional metadata
    created_at TEXT NOT NULL, -- ISO 8601 datetime
    updated_at TEXT NOT NULL, -- ISO 8601 datetime
    FOREIGN KEY (data_source_id) REFERENCES data_sources(id) ON DELETE CASCADE
);

-- Create custom provider templates table
CREATE TABLE IF NOT EXISTS custom_provider_templates (
    id TEXT PRIMARY KEY NOT NULL,
    name TEXT NOT NULL,
    description TEXT NOT NULL DEFAULT '',
    icon TEXT NOT NULL DEFAULT '',
    base_uri TEXT NOT NULL,
    required_credentials TEXT NOT NULL, -- JSON array of credential field names
    default_settings TEXT NOT NULL DEFAULT '{}', -- JSON object for default settings
    available_models TEXT NOT NULL DEFAULT '[]', -- JSON array of model IDs
    embedding_request_template TEXT NOT NULL, -- JSON object for HttpRequestTemplate
    created_at TEXT NOT NULL, -- ISO 8601 datetime
    updated_at TEXT NOT NULL  -- ISO 8601 datetime
);

-- Create provider configurations table
CREATE TABLE IF NOT EXISTS providers (
    id TEXT PRIMARY KEY NOT NULL,
    name TEXT NOT NULL,
    description TEXT NOT NULL DEFAULT '',
    type TEXT NOT NULL, -- openai, gemini, custom
    custom_template_id TEXT, -- Reference to custom_provider_templates for custom providers
    settings TEXT NOT NULL DEFAULT '{}', -- JSON object for provider-specific settings
    enabled_models TEXT NOT NULL DEFAULT '[]', -- JSON array of enabled model IDs
    created_at TEXT NOT NULL, -- ISO 8601 datetime
    updated_at TEXT NOT NULL, -- ISO 8601 datetime
    FOREIGN KEY (custom_template_id) REFERENCES custom_provider_templates(id) ON DELETE CASCADE
);

-- Create credentials table (separate from provider configs)
CREATE TABLE IF NOT EXISTS provider_credentials (
    provider_id TEXT PRIMARY KEY NOT NULL, -- Reference to providers
    credential TEXT NOT NULL, -- JSON of Credential object
    FOREIGN KEY (provider_id) REFERENCES providers(id) ON DELETE CASCADE
);

-- Create jobs table
CREATE TABLE IF NOT EXISTS jobs (
    id TEXT PRIMARY KEY NOT NULL,
    name TEXT NOT NULL,
    description TEXT NOT NULL DEFAULT '',
    data_source_id TEXT NOT NULL,
    template_id TEXT NOT NULL,
    provider_ids TEXT NOT NULL, -- JSON array of provider IDs
    status TEXT NOT NULL DEFAULT 'pending', -- pending, running, completed, failed, cancelled
    created_at TEXT NOT NULL, -- ISO 8601 datetime
    started_at TEXT, -- ISO 8601 datetime, nullable
    completed_at TEXT, -- ISO 8601 datetime, nullable
    error_message TEXT, -- Error details if job failed
    results TEXT, -- JSON object containing job results
    total_records INTEGER, -- Total number of records to process
    processed_records INTEGER DEFAULT 0, -- Number of records processed so far
    FOREIGN KEY (data_source_id) REFERENCES data_sources(id) ON DELETE CASCADE,
    FOREIGN KEY (template_id) REFERENCES templates(id) ON DELETE CASCADE
);

-- Create junction table for job-provider relationships (many-to-many)
CREATE TABLE IF NOT EXISTS job_providers (
    job_id TEXT NOT NULL,
    provider_id TEXT NOT NULL,
    PRIMARY KEY (job_id, provider_id),
    FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE,
    FOREIGN KEY (provider_id) REFERENCES providers(id) ON DELETE CASCADE
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_templates_data_source_id ON templates(data_source_id);
CREATE INDEX IF NOT EXISTS idx_providers_type ON providers(type);
CREATE INDEX IF NOT EXISTS idx_providers_custom_template_id ON providers(custom_template_id);
CREATE INDEX IF NOT EXISTS idx_provider_credentials_provider_id ON provider_credentials(provider_id);
CREATE INDEX IF NOT EXISTS idx_jobs_status ON jobs(status);
CREATE INDEX IF NOT EXISTS idx_jobs_data_source_id ON jobs(data_source_id);
CREATE INDEX IF NOT EXISTS idx_jobs_template_id ON jobs(template_id);
CREATE INDEX IF NOT EXISTS idx_jobs_created_at ON jobs(created_at);
''',
    down: '''
DROP TABLE IF EXISTS job_providers;
DROP TABLE IF EXISTS jobs;
DROP TABLE IF EXISTS provider_credentials;
DROP TABLE IF EXISTS providers;
DROP TABLE IF EXISTS custom_provider_templates;
DROP TABLE IF EXISTS templates;
DROP TABLE IF EXISTS data_sources;
''',
  );
}
