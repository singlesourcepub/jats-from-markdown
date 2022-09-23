PANDOC = pandoc
TALK_FILE=talk.md
REVEALJS_TGZ = https://github.com/hakimel/reveal.js/archive/4.2.1.tar.gz

article.jats.xml: index.md filters/abstract-to-meta.lua
	$(PANDOC) \
	    --defaults=data/jats.yaml \
	    --to=jats_articleauthoring \
	    --output=$@ \
	    $<

article.pdf: index.md filters/abstract-to-meta.lua
	$(PANDOC) \
	    --defaults=data/latex.yaml \
	    --to=latex \
	    --pdf-engine=lualatex \
	    --output=$@ \
	    $<

talk.html: $(TALK_FILE) reveal.js
	$(PANDOC) \
	    --defaults=data/talk.yaml \
	    --output=$@ \
	    $<

reveal.js:
	mkdir -p reveal.js
	curl --location -Ss $(REVEALJS_TGZ) | \
		tar zvxf - -C $@ --strip-components 1

.PHONY: watch
watch:
	find . -type f \! -path './.git/*' \! -path './reveal.js/*' | entr make talk.html

.PHONY: clean
clean:
	rm -f talk.html
