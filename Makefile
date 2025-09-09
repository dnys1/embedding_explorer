ROOT:=$(PWD)

.PHONY: bindings
bindings:
	( cd $(HOME)/dev/web/web_generator && dart run bin/gen_interop_bindings.dart --config=$(ROOT)/monaco.yaml )

.PHONY: build
build:
	( cd web && pnpm install && pnpm run build && cd .. && jaspr build )

.PHONY: serve
serve:
	( cd web && pnpm install && pnpm run build:dev && cd .. && jaspr serve )
