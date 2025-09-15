import '../../../database/migration.dart';

Migration get migration {
  return Migration.fromStrings(
    version: 3,
    up: '''
-- Checkpoints table to track job progress and state
CREATE TABLE IF NOT EXISTS job_checkpoints (
  id TEXT PRIMARY KEY,
  job_id TEXT NOT NULL,
  type TEXT NOT NULL,
  timestamp TEXT NOT NULL,
  data TEXT NOT NULL,
  sequence_number INTEGER NOT NULL,
  provider_id TEXT,
  batch_number INTEGER,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (job_id) REFERENCES jobs (id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_job_checkpoints_job_id ON job_checkpoints (job_id);
CREATE INDEX IF NOT EXISTS idx_job_checkpoints_sequence ON job_checkpoints (job_id, sequence_number);
CREATE INDEX IF NOT EXISTS idx_job_checkpoints_type ON job_checkpoints (job_id, type);
''',
    down: '''
DROP INDEX IF EXISTS idx_job_checkpoints_type;
DROP INDEX IF EXISTS idx_job_checkpoints_sequence;
DROP INDEX IF EXISTS idx_job_checkpoints_job_id;  
DROP TABLE IF EXISTS job_checkpoints;
''',
  );
}
