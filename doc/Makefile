# <LICENSE
#   Copyright (c) 2013, 2014 Jean-Luc Thiffeault
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

# Build everything.
all: $(PDFFILES)

$(MASTERFILE).pdf: $(MASTERFILE).tex $(MASTERFILE).bib
	@$(LATEXCMD) $(MASTERFILE).tex
	@bibtex $(MASTERFILE)
	@$(LATEXCMD) $(MASTERFILE).tex
	@makeindex $(MASTERFILE)
	@$(LATEXCMD) $(MASTERFILE).tex
	@$(LATEXCMD) $(MASTERFILE).tex

clean:
	rmtex $(MASTERFILE)
