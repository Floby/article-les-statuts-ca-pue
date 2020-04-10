.PHONY: help

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build: html config style dist/assets wip .silent ## Build landing pages inside ./dist/

dev: install ## `make build` every second and serve landing page locally on port 8888
	npx concurrently --names 'build,serve,open' \
		--prefix-colors 'yellow.dim,cyan.dim' \
		'make --no-print-directory watch-build' \
		'npx http-server -p 8888 dist/' \
		'npx open-cli http://localhost:8888/'

install: ## install necessary dependencies
	npm ci

watch-build: install
	$(MAKE) build || beep
	while sleep 1; do $(MAKE) build || beep ; done

dist/assets: assets/*
	cp -r assets dist/assets

wip: dist/wip.bundle.js

dist/wip.bundle.js: wip.js src/*.js
	@echo BUILD $@ because these changed: $?
	npx browserify wip.js -o dist/wip.bundle.js && \
		cp wip.html dist/

SRC_HTML := $(wildcard ./*.html)
DIST_HTML := $(patsubst ./%.html,dist/%.html,$(SRC_HTML))

html: $(DIST_HTML)

dist/%.html: ./%.html
	@mkdir -p dist
	cp $< $@

SRC_STYLE := $(wildcard ./*.css)
DIST_STYLE := $(patsubst ./%.css,dist/%.css,$(SRC_STYLE))
style: $(DIST_STYLE)

dist/%.css: ./%.css
	@mkdir -p dist
	cp $< $@

config: dist/config.template.js dist/config.js

dist/config.template.js: config.js
	cp config.js dist/config.template.js

dist/config.js: config.js .env
	cat config.js | env $$(cat .env 2>/dev/null || echo '') envsubst > dist/config.js

.env:
	echo -n '' >> .env

clean:
	rm -rf dist


.silent:
	@echo '' >/dev/null

