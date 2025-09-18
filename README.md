# Embedding Explorer

Minimal web app for experimenting with and comparing text embedding models. It lets you ingest data, generate embeddings using different providers, store them, and run fast similarity searches so you can evaluate model quality side‑by‑side. All local to your browser.

## Why

Choosing an embedding model is tedious: you repeat ad‑hoc scripts, switch endpoints, and copy/paste vectors into notebooks. This tool gives you a consistent workflow to:

- Ingest and (re)embed content with multiple models
- Compare nearest‑neighbor results across models instantly
- Inspect vector distances & metadata in a browser UI
- Prototype downstream retrieval (RAG) scoring without wiring a full backend

## Tech Stack

- **Dart** – Single language for UI, background workers, and data tasks
- **Jaspr** – Dart web framework for rendering + interactive components
- **LibSQL** – Persistent store for documents, metadata, and embedding vectors
  - Uses the experimental [LibSQL WASM](https://github.com/tursodatabase/libsql-wasm-experimental) package for browser storage via OPFS

## Core Features

- Multi‑model embedding generation
- Vector storage & similarity (k‑NN / cosine) queries
- Interactive comparison view (result lists per model)
- Batch ingestion & re‑embedding jobs with progress tracking

## Project Layout

```
lib/
	database/        # LibSQL pool, migrations, transactions
	embeddings/      # Embedding services & interop
	data_sources/    # Data acquisition & ingest logic
	jobs/            # Background / batch job abstractions
	storage/         # Storage service abstractions
	util/            # Shared helpers (logging, retry, etc.)
	workers/         # Generated worker entrypoints
web/               # Front-end entrypoint & static assets
test/              # Unit & integration tests
```
