# .SUFFIXES: .html .md
PROJECT:=$(shell basename `pwd`)
BASEDIR:=$(shell echo `pwd`)
REVEAL_THEMES := reveal.js/dist/theme

########## config.mk 
# config.mk is expected to set:
# REMOTE_USER:= "marcus"
# REMOTE_HOST := "hardt-it.de"
# REMOTE_DIR := "public_html"
# REMOTE_URL := "http://${REMOTE_USER}.${REMOTE_HOST}/${PROJECT}"
# REVEAL_USER := ${REMOTE_USER}
# REVEAL_HOST := ${REMOTE_USER}.${REMOTE_HOST}
# REVEAL_DIR  := "public_html/reveal.js"
# REVEAL_URL_DIR := "/reveal.js"
# REVEAL_URL := "${REVEAL_URL_DIR}"
-include config.mk
-include ${HOME}/.config/make-reveal/config.mk



### Read more config from markdown file header:
# REMOTE_USER
TEMP:=$(shell grep -B 100 '\-\-\-' $(PROJECT).md | grep ^REMOTE_USER: | cut -d:  -f 2 | sed s/\ *//)
ifneq ($(TEMP),)
REMOTE_USER:=${TEMP}
XY:="aaa"
endif

# REMOTE_HOST
TEMP:=$(shell grep -B 100 '\-\-\-' $(PROJECT).md | grep ^REMOTE_HOST: | cut -d:  -f 2 | sed s/\ *//)
ifneq ($(TEMP),)
REMOTE_HOST:=${TEMP}
XY:="aaa"
endif

# REMOTE_URL
PROTO:=$(shell grep -B 100 '\-\-\-' $(PROJECT).md | grep ^REMOTE_URL: | cut -d:  -f 2  | sed s#\ *##)
TEMP:=$(shell grep -B 100 '\-\-\-' $(PROJECT).md | grep ^REMOTE_URL: | cut -d:  -f 3  | sed s#\ *##)
ifneq ($(TEMP),)
REMOTE_URL :=${PROTO}:${TEMP}
endif

# REVEAL_DIR
TEMP:=$(shell grep -B 100 '\-\-\-' $(PROJECT).md | grep ^REVEAL_DIR:  | cut -d:  -f 2 | sed s/\ *//)
ifneq ($(TEMP),)
REVEAL_DIR :=${TEMP}
endif

# REVEAL_URL
TEMP:=$(shell grep -B 100 '\-\-\-' $(PROJECT).md | grep ^REVEAL_URL:  | cut -d:  -f 2 | sed s/\ *//)
ifneq ($(TEMP),)
REVEAL_URL :=${TEMP}
endif

### Derive Variables:

REMOTE := ${REMOTE_HOST}:~/${REMOTE_DIR}/${PROJECT}
REVEAL := ${REVEAL_HOST}:~/${REVEAL_DIR}

vpath %.md markdown
vpath %.html html

.DEFAULT_GOAL := default

info:
	@echo "REMOTE_USER: ${REMOTE_USER} "
	@echo "REMOTE_HOST: ${REMOTE_HOST} "
	@echo "REMOTE_DIR:  ${REMOTE_DIR}  "
	@echo "REMOTE_URL:  ${REMOTE_URL}  "
	@echo "REVEAL_USER: ${REVEAL_USER} "
	@echo "REVEAL_HOST: ${REVEAL_HOST} "
	@echo "REVEAL_DIR:  ${REVEAL_DIR}  "
	@echo "REVEAL_URL:  ${REVEAL_URL}  "
	@echo ""
	@echo "REVEAL:      ${REVEAL}      "
	@echo "REMOTE:      ${REMOTE}      "
	@echo "PROJECT:     ${PROJECT}     "

%.html: %.md reveal.js
	@pandoc -t revealjs --mathml --standalone -f markdown   -V highlightjs -V highlightjs-theme:monokai -V revealjs-url=reveal.js -o $@-preview.html $<
	@pandoc -t revealjs --mathml --standalone -f markdown   -V highlightjs -V highlightjs-theme:monokai -V revealjs-url=$(REVEAL_URL) -o $@ $<
	# @pandoc -t revealjs --mathml --standalone -f markdown  -V highlightjs -V higlighjs-theme:monokai -L ~/projects/lua-filters/revealjs-codeblock/revealjs-codeblock.lua  -V revealjs-url=reveal.js -o $@-preview.html $<
	# @pandoc -t revealjs --mathml --standalone -f markdown  -V highlightjs -V higlighjs-theme:monokai -L ~/projects/lua-filters/revealjs-codeblock/revealjs-codeblock.lua  -V revealjs-url=$(REVEAL_URL) -o $@ $<
	@#pandoc -t revealjs --mathml --standalone -f markdown  -V revealjs-url=reveal.js -o $@-preview.html $<
	@#pandoc -t revealjs --mathml --standalone -f markdown  -V revealjs-url=$(REVEAL_URL) -o $@ $<
	@#pandoc -t revealjs --webtex --standalone -f markdown  -V revealjs-url=reveal.js -o $@-preview.html $<
	@#    pandoc -t revealjs --webtex --standalone -f markdown  -V revealjs-url=$(REVEAL_URL) -o $@ $<
	@#pandoc -t revealjs --standalone -f markdown -o $@ $<
	@#pandoc -t revealjs --mathjax --self-contained --standalone -f markdown -o $@ $<
	@#pandoc -t revealjs           --self-contained --standalone -f markdown -o $@ $<

remote-reveal: reveal.js
	@#@ssh ${REVEAL_HOST} 'test -d ${REVEAL_DIR} && rm -rf ${REVEAL_DIR}'
	@#scp -rp reveal.js ${REVEAL}
	@echo rsync -rlutopgx reveal.js/ ${REVEAL_USER}@${REVEAL}/
	@rsync -rlutopgx reveal.js/ ${REVEAL_USER}@${REVEAL}/

default: ${PROJECT}.html
	@echo ""

reveal.js: 
	@git clone https://github.com/hakimel/reveal.js.git  > /dev/null 2>&1
	# @git clone https://github.com/hakimel/reveal.js.git -b 4.4.0 > /dev/null 2>&1
	#@git clone https://github.com/hakimel/reveal.js.git -b 3.9.2 > /dev/null 2>&1
	@#curl -s marcus.hardt-it.de/reveal-theme-marcus.css > $(REVEAL_THEMES)/marcus.css
	@curl -s https://marcus.hardt-it.de/reveal-themes/marcus.css > $(REVEAL_THEMES)/marcus.css
	@curl -s https://marcus.hardt-it.de/reveal-themes/marcus-large.css > $(REVEAL_THEMES)/marcus-large.css
	@curl -s https://marcus.hardt-it.de/reveal-themes/marcus-black.css > $(REVEAL_THEMES)/marcus-black.css
	@curl -s https://marcus.hardt-it.de/reveal-themes/marcus-black-large.css > $(REVEAL_THEMES)/marcus-black-large.css
	@curl -s https://marcus.hardt-it.de/reveal-themes/marcus-common.css > $(REVEAL_THEMES)/marcus-common.css
	@curl -s https://marcus.hardt-it.de/reveal-themes/mytoken.css > $(REVEAL_THEMES)/mytoken.css
	@test -d images || mkdir images

publish: reveal.js default
	@echo  "Publishing to $(REMOTE_URL)"
	@ssh ${REMOTE_USER}@${REMOTE_HOST} "cd ${REMOTE_DIR}/; test -e `basename ${REMOTE}` || mkdir `basename ${REMOTE}`"
	@scp ${PROJECT}.html ${REMOTE_USER}@${REMOTE}/index.html > /dev/null 
	@rsync -rlutopgx images ${REMOTE_USER}@${REMOTE}/
	@ssh ${REMOTE_USER}@${REMOTE_HOST} "chmod -R og+r ${REMOTE_DIR}/`basename ${REMOTE}`"

view-remote: publish
	@xdg-open $(REMOTE_URL) >/dev/null 2>&1 &

view: reveal.js default
	@xdg-open file://$(BASEDIR)/$(PROJECT).html-preview.html >/dev/null 2>&1 & 

publish-all: publish
	@ssh hardt-it.de "cd web/`basename ${REMOTE}`; test -e reveal.js || ln -s ../reveal.js ."

.PHONY: clean
clean:
	rm -f *.html *.pdf
	rm -f screenshots/*

.PHONY: distclean
distclean: clean
	rm -rf reveal.js

.PHONY: pdf
pdf: ${PROJECT}.html
	test -d screenshots || mkdir screenshots
	docker run -it --rm -t -v `pwd`:/slides -v `pwd`:/home/user astefanutti/decktape \
		reveal \
		-s 1920x1200 \
		--screenshots \
		--screenshots-size=1920x1200 \
		--screenshots-format png \
		--screenshots-directory screenshots \
		--chrome-arg=--disable-web-security \
		/home/user/${PROJECT}.html-preview.html \
		${PROJECT}-delme.pdf
	rm ${PROJECT}-delme.pdf
	
	convert `find screenshots -type f| sort -t_ -n -k2` ${PROJECT}.pdf
