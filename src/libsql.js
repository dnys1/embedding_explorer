// LibSQL WASM bundle
import * as loadLibsql from "@libsql/libsql-wasm-experimental";

// Export libsql utilities globally
globalThis.libsqlLoader = loadLibsql;
