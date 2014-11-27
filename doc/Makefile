# <LICENSE
#   Braidlab: a Matlab package for analyzing data using braids
#
#   http://github.com/jeanluct/braidlab
#
#   Copyright (C) 2013-2015  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
#                            Marko Budisic         <marko@math.wisc.edu>
#
#   This file is part of Braidlab.
#
#   Braidlab is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   Braidlab is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with Braidlab.  If not, see <http://www.gnu.org/licenses/>.
# LICENSE>

LATEXCMD = pdflatex -shell-escape
MASTERFILE = braidlab_guide
PDFFILES = $(MASTERFILE).pdf

.PHONY: all clean distclean

# Build everything.
all: $(PDFFILES)

$(MASTERFILE).pdf: $(MASTERFILE).tex $(MASTERFILE).bib
	@$(LATEXCMD) $(MASTERFILE).tex
	@bibtex $(MASTERFILE)
	@$(LATEXCMD) $(MASTERFILE).tex
	@makeindex $(MASTERFILE)
	@$(LATEXCMD) $(MASTERFILE).tex
	@$(LATEXCMD) $(MASTERFILE).tex
	@$(LATEXCMD) $(MASTERFILE).tex

clean:
	# Remove latex clutter.
	rm -f *.aux *.bbl *.blg *.idx *.ilg *.ind *.log *.out *.toc

distclean: clean
	# Revert PDF file to latest revision.
	hg revert -C $(MASTERFILE).pdf
	# Update timestamp so make knows to remake the file.
	touch -d "`hg parent  $(MASTERFILE).pdf -T '{date|isodate}\n'`" \
		$(MASTERFILE).pdf
