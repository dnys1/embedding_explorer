import { defineConfig } from "vite";
import { fileURLToPath } from "node:url";

export default defineConfig(({ mode }) => ({
  // Set base path for assets
  base: "./",

  // Entry points for our JS bundles
  build: {
    outDir: "js",
    emptyOutDir: true,
    minify: mode === "production",
    sourcemap: true,
    rollupOptions: {
      input: {
        monaco: "./src/monaco.js",
        libsql: "./src/libsql.js",
        // Monaco Editor workers
        "editor.worker": "monaco-editor/esm/vs/editor/editor.worker.js",
        "json.worker": "monaco-editor/esm/vs/language/json/json.worker.js",
        "css.worker": "monaco-editor/esm/vs/language/css/css.worker.js",
        "html.worker": "monaco-editor/esm/vs/language/html/html.worker.js",
        "ts.worker": "monaco-editor/esm/vs/language/typescript/ts.worker.js",
      },
      output: {
        entryFileNames: "[name].js",
        chunkFileNames: "[name]-[hash].js",
        assetFileNames: "[name].[ext]",
      },
    },
  },

  // Development server configuration
  server: {
    port: 3000,
    open: false,
  },

  // Optimize dependencies
  optimizeDeps: {
    include: [
      "monaco-editor",
      "monaco-editor/esm/vs/editor/editor.worker.js",
      "monaco-editor/esm/vs/language/json/json.worker.js",
      "monaco-editor/esm/vs/language/css/css.worker.js",
      "monaco-editor/esm/vs/language/html/html.worker.js",
      "monaco-editor/esm/vs/language/typescript/ts.worker.js",
      "@libsql/libsql-wasm-experimental",
    ],
  },

  // Worker handling
  worker: {
    format: "es",
  },
}));
