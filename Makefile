ROOT:=$(PWD)

.PHONY: bindings
bindings:
	( cd $(HOME)/dev/web/web_generator && dart run bin/gen_interop_bindings.dart --config=$(ROOT)/monaco.yaml )

.PHONY: build
build:
	( cd web && pnpm install && pnpm run build && cd .. && jaspr build --include-source-maps )
	@rm -rf build/jaspr/node_modules
	@rm -rf build/jaspr/.gitignore
	@rm -rf build/jaspr/package.json
	@rm -rf build/jaspr/pnpm-lock.yaml
	@rm -rf build/jaspr/styles.tw.css
	@rm -rf build/jaspr/tailwind.config.js
	@rm -rf build/jaspr/tsconfig.json
	@rm -rf build/jaspr/vite.config.js

.PHONY: serve
serve:
	( cd web && pnpm install && pnpm run build:dev && cd .. && webdev serve )

.PHONY: serve-build
serve-build: build
	dhttpd --path build/jaspr --port 8080 --headers='Cross-Origin-Embedder-Policy: require-corp;Cross-Origin-Opener-Policy: same-origin'
