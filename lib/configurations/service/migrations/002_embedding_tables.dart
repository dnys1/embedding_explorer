import '../../../database/migration.dart';

Migration get migration {
  return Migration.fromStrings(
    version: 2,
    up: '''
-- Create embedding table registry to track dynamically created embedding tables
CREATE TABLE IF NOT EXISTS embedding_table_registry (
    id TEXT PRIMARY KEY NOT NULL,
    table_name TEXT NOT NULL UNIQUE,
    job_id TEXT NOT NULL,
    data_source_id TEXT NOT NULL,
    embedding_template_id TEXT NOT NULL,
    description TEXT NOT NULL DEFAULT '',
    created_at TEXT NOT NULL, -- ISO 8601 datetime
    updated_at TEXT NOT NULL, -- ISO 8601 datetime
    FOREIGN KEY (job_id) REFERENCES embedding_jobs(id) ON DELETE CASCADE,
    FOREIGN KEY (data_source_id) REFERENCES data_source_configs(id) ON DELETE CASCADE,
    FOREIGN KEY (embedding_template_id) REFERENCES embedding_template_configs(id) ON DELETE CASCADE
);

-- Create embedding column registry to track vector columns in embedding tables
CREATE TABLE IF NOT EXISTS embedding_column_registry (
    id TEXT PRIMARY KEY NOT NULL,
    table_id TEXT NOT NULL,
    column_name TEXT NOT NULL,
    model_provider_id TEXT NOT NULL,
    model_name TEXT NOT NULL,
    vector_type TEXT NOT NULL, -- F32_BLOB, F16_BLOB, etc.
    dimensions INTEGER NOT NULL,
    created_at TEXT NOT NULL, -- ISO 8601 datetime
    UNIQUE(table_id, column_name),
    FOREIGN KEY (table_id) REFERENCES embedding_table_registry(id) ON DELETE CASCADE,
    FOREIGN KEY (model_provider_id) REFERENCES model_provider_configs(id) ON DELETE CASCADE
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_embedding_table_registry_job_id ON embedding_table_registry(job_id);
CREATE INDEX IF NOT EXISTS idx_embedding_table_registry_data_source_id ON embedding_table_registry(data_source_id);
CREATE INDEX IF NOT EXISTS idx_embedding_table_registry_embedding_template_id ON embedding_table_registry(embedding_template_id);
CREATE INDEX IF NOT EXISTS idx_embedding_column_registry_table_id ON embedding_column_registry(table_id);
CREATE INDEX IF NOT EXISTS idx_embedding_column_registry_model_provider_id ON embedding_column_registry(model_provider_id);
''',
    down: '''
-- Drop indexes
DROP INDEX IF EXISTS idx_embedding_column_registry_model_provider_id;
DROP INDEX IF EXISTS idx_embedding_column_registry_table_id;
DROP INDEX IF EXISTS idx_embedding_table_registry_embedding_template_id;
DROP INDEX IF EXISTS idx_embedding_table_registry_data_source_id;
DROP INDEX IF EXISTS idx_embedding_table_registry_job_id;

-- Drop tables
DROP TABLE IF EXISTS embedding_column_registry;
DROP TABLE IF EXISTS embedding_table_registry;
''',
  );
}
