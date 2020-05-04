.PHONY: help

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build: html images ## Build landing pages inside ./dist/

html: 
	@mkdir -p dist
	npx marked -o dist/index.html article.md

GRAPH_STYLE := $(wildcard graphs/*.gv)
DIST_STYLE := $(patsubst graphs/%.gv,dist/%.png,$(GRAPH_STYLE))
images: $(DIST_STYLE)

dist/%.png: graphs/%.gv
	@mkdir -p dist
	dot -Tpng $< -o $@

clean: ## Remove dist
	rm -rf dist
