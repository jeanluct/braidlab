PDFFILES = braidlab_guide.pdf

# Build everything.
all: $(PDFFILES)

braidlab_guide.pdf: braidlab_guide.tex braidlab_guide.bib
	@pdflatex braidlab_guide.tex
	@bibtex braidlab_guide
	@pdflatex braidlab_guide.tex
	@makeindex braidlab_guide
	@pdflatex braidlab_guide.tex
	@pdflatex braidlab_guide.tex

clean:
	rmtex braidlab_guide
