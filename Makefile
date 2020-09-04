.PHONY: help

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build: html static images ## Build landing pages inside ./dist/

static: dist/assets

ARTICLE_SRC := $(wildcard article.*.md)
ARTICLE_DIST := $(patsubst article.%.md,dist/%.html,$(ARTICLE_SRC))
html: $(ARTICLE_DIST) dist/index.html

dist/index.html: dist/0.html
	cp dist/0.html dist/index.html

dist/%.html: article.%.md layout.sh
	@mkdir -p dist
	npx marked $< | ./layout.sh > $@


GRAPH_GRAPH := $(wildcard graphs/*.gv)
DIST_GRAPH := $(patsubst graphs/%.gv,dist/%.png,$(GRAPH_GRAPH))
images: $(DIST_GRAPH)

dist/assets: assets/*
	@mkdir -p dist/assets
	rm -rf dist/assets/*
	cp -r assets/* dist/assets

dist/%.png: graphs/%.gv
	@mkdir -p dist
	dot -Tpng $< -o $@

clean: ## Remove dist
	rm -rf dist
