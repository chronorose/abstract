.PHONY: all

FILTERS := $(wildcard filters/*.lua)

PANDOC_ARGS := -t latex --pdf-engine xelatex
PANDOC_ARGS += --citeproc
PANDOC_ARGS += --include-in-header=header.tex
PANDOC_ARGS += $(FILTERS:%=--lua-filter %)
PANDOC_ARGS += --number-sections
PANDOC_ARGS += --listings
PANDOC_ARGS += -V documentclass=article
PANDOC_ARGS += -V fontsize=12pt
PANDOC_ARGS += -V papersize=a4

all:

build/title.pdf: title.tex | build/
	pdflatex -output-directory=build/ $<

build/main.tex: main.md header.tex $(FILTERS) | build/
	pandoc $(PANDOC_ARGS) $< --standalone -o $@

build/main.pdf: main.md header.tex $(FILTERS) | build/
	pandoc $(PANDOC_ARGS) $< -o $@

build/print.pdf: build/title.pdf build/main.pdf
	pdfunite $^ $@

build/:
	mkdir $@

clean:
	@rm -rf build/
