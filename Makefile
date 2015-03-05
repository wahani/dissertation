# Usually, only these lines need changing
TEXFILE= main
RDIR= ./R
RMDDIR= ./Rmd
TEXDIR= ./tex
FIGDIR= ./figs

# list R files
RFILES := $(wildcard $(RDIR)/*.R)
# Indicator files to show R file has run
OUT_FILES:= $(RFILES:.R=.Rout)
# list R-markdown files
RMD_FILES:= $(wildcard $(RMDDIR)/*.Rmd)
MD_FILES:= $(RMD_FILES:.Rmd=.md)
TEX_RMD_FILES:= $(RMD_FILES:.Rmd=.tex)
TEX_FILES:= $(wildcard $(TEXDIR)/*.tex)

all: $(TEXFILE).pdf $(OUT_FILES) $(TEX_FILES) $(TEX_RMD_FILES) $(MD_FILES)

# RUN EVERY R FILE
$(RDIR)/%.Rout: $(RDIR)/%.R
	R CMD BATCH $< $@

# Run Rmd>md>tex
$(RMDDIR)/%.md: $(RMDDIR)/%.Rmd
	Rscript build.R $< $@

$(RMDDIR)/%.tex	: $(RMDDIR)/%.md
	pandoc --biblatex --data-dir=./ -o $@ $<

# Compile main tex file and show errors
$(TEXFILE).pdf: ./*.tex ./*.bib $(TEX_FILES) $(TEX_RMD_FILES) $(OUT_FILES)
	latexmk -pdf -quiet $(TEXFILE)
	latexmk -c

watch:
	Rscript -e 'wahaniMiscs::watch()'

clean:
	rm -fv $(OUT_FILES)
	rm -fv *.aux *.log *.toc *.blg *.bbl *.synctex.gz
	rm -fv *.out *.bcf *blx.bib *.run.xml *.lol
	rm -fv *.fdb_latexmk *.fls
	rm -fv $(RMDDIR)/*.aux $(RMDDIR)/*.tex.aux
	rm -fv $(TEXDIR)/*.aux $(TEXDIR)/*.tex.aux

.PHONY: clean watch
