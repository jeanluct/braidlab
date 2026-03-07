# <LICENSE
#   Braidlab: a Matlab package for analyzing data using braids
#
#   https://github.com/jeanluct/braidlab
#
#   Copyright (C) 2013-2026  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
#                            Marko Budisic          <mbudisic@gmail.com>
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
#   along with Braidlab.  If not, see <https://www.gnu.org/licenses/>.
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
	rm -f \
		*.aux *.bbl *.blg \
		*.fdb_latexmk *.fls *.idx *.ilg *.ind *.log *.out *.toc

distclean: clean
	# Revert PDF file to latest revision.
	git checkout $(MASTERFILE).pdf
	# Update timestamp so make knows to remake the file. Use a single
	# sh -c invocation to avoid multi-line continuation issues in make.
	@sh -c 'os=$$(uname -s); if [ "$$os" = "Linux" ]; then touch -r "$(MASTERFILE).pdf" -d "-1 second" "$(MASTERFILE).pdf"; elif [ "$$os" = "Darwin" ]; then T=$$(stat -f %m "$(MASTERFILE).pdf"); Tprev=$$((T-1)); DATE=$$(date -r $$Tprev +%Y%m%d%H%M.%S); touch -t $$DATE "$(MASTERFILE).pdf"; else echo "Warning: unknown OS ($$os); PDF mtime not adjusted"; fi'
	touch $(MASTERFILE).tex
