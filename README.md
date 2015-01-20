This is a description in draft form of how I got here. You do not have to read it. The repository comes with a Makefile which you can use. `make watch` will check with `make -q` if something needs to be done and if so runs `make`. If you want to use this template make sure, that you have installed:
- R -- add to PATH if in win
    -  knitr
    -  wahaniMiscs: `devtools::install_github("wahani/wahaniMiscs")`
- pandoc -- add to PATH if in win
- make -- add to PATH if in win
- Latex

# Resources

- [R/Latex Makefile](http://robjhyndman.com/hyndsight/makefiles/)
- Latex thesis-template I use (http://www.latextemplates.com/template/classicthesis-typographic-thesis)
    - UTF-8 instead latin9
    - biblatex instead of natbib
    - added things for graphics and code as below
  
# From *.rmd to *.md

Use `knitr`

```
knitr::knit("../dissRepo/diss/rmrkdwn.rmd", "../dissRepo/diss/rmrkdwn.md")
```

This will be done in a R source file `build.R` which can be called with arguments `in` and `out`... This is done in the `Makefile`.


# From *.md to *.tex

This works with pandoc. Use pandoc citation and process the files with option `biblatex` on each *.md file.

```
pandoc --biblatex -o test.tex test.md
```

## `test.md`:

```
# new section

- item
  - item 1.1
  - item 1.2

$$x_i = y_i$$

cite me: @Sch12
```

## `test.tex`

```
\section{new section}\label{new-section}

\begin{itemize}
\itemsep1pt\parskip0pt\parsep0pt
\item
  item

  \begin{itemize}
  \itemsep1pt\parskip0pt\parsep0pt
  \item
    item 1.1
  \item
    item 1.2
  \end{itemize}
\end{itemize}

\[x_i = y_i\]

cite me: \textcite{Sch12}
```

## For citation

Use  

```
\addbibresource{Datenbank.bib}
```

for adding your bib database, biber has problems with bibliography...

## For Code-Blocks

If you have code in your doc you need to include the highlighting syntax normally produced by pandoc. pandoc will still use the commands, but not include a header automatically, you have to specify that yourself. This is what is used when specifying the option `--highlight-style tango` (default from RStudio):

```
% use upquote if available, for straight quotes in verbatim environments
\IfFileExists{upquote.sty}{\usepackage{upquote}}{}
% use microtype if available
\IfFileExists{microtype.sty}{\usepackage{microtype}}{}
\usepackage{biblatex}
\usepackage{color}
\usepackage{fancyvrb}
\newcommand{\VerbBar}{|}
\newcommand{\VERB}{\Verb[commandchars=\\\{\}]}
\DefineVerbatimEnvironment{Highlighting}{Verbatim}{commandchars=\\\{\}}
% Add ',fontsize=\small' for more characters per line
\usepackage{framed}
\definecolor{shadecolor}{RGB}{248,248,248}
\newenvironment{Shaded}{\begin{snugshade}}{\end{snugshade}}
\newcommand{\KeywordTok}[1]{\textcolor[rgb]{0.13,0.29,0.53}{\textbf{{#1}}}}
\newcommand{\DataTypeTok}[1]{\textcolor[rgb]{0.13,0.29,0.53}{{#1}}}
\newcommand{\DecValTok}[1]{\textcolor[rgb]{0.00,0.00,0.81}{{#1}}}
\newcommand{\BaseNTok}[1]{\textcolor[rgb]{0.00,0.00,0.81}{{#1}}}
\newcommand{\FloatTok}[1]{\textcolor[rgb]{0.00,0.00,0.81}{{#1}}}
\newcommand{\CharTok}[1]{\textcolor[rgb]{0.31,0.60,0.02}{{#1}}}
\newcommand{\StringTok}[1]{\textcolor[rgb]{0.31,0.60,0.02}{{#1}}}
\newcommand{\CommentTok}[1]{\textcolor[rgb]{0.56,0.35,0.01}{\textit{{#1}}}}
\newcommand{\OtherTok}[1]{\textcolor[rgb]{0.56,0.35,0.01}{{#1}}}
\newcommand{\AlertTok}[1]{\textcolor[rgb]{0.94,0.16,0.16}{{#1}}}
\newcommand{\FunctionTok}[1]{\textcolor[rgb]{0.00,0.00,0.00}{{#1}}}
\newcommand{\RegionMarkerTok}[1]{{#1}}
\newcommand{\ErrorTok}[1]{\textbf{{#1}}}
\newcommand{\NormalTok}[1]{{#1}}
```

## For figures

This controls that a figure is not larger than the boundaries of your page, somehow...
```
\usepackage{graphicx}
\makeatletter
\def\maxwidth{\ifdim\Gin@nat@width>\linewidth\linewidth\else\Gin@nat@width\fi}
\def\maxheight{\ifdim\Gin@nat@height>\textheight\textheight\else\Gin@nat@height\fi}
\makeatother
\setkeys{Gin}{width=\maxwidth,height=\maxheight,keepaspectratio}
```



## From *.tex to *.pdf

For this I want to use `latexmk`. For some reason I get an error for some perl package `PATH` but am unable to find out how to update it. I tried to update perl, but miktex seems to have its own verison which I don't know how to update...

I will use texLive instead and see what happens... And it works out of the box... whatever...

To update the pdf and citations, refs, etc. use

```
latexmk -pdf -pv rmrkdwn.tex
```

and clean-up

```
latexmk -c
```

# Folder structure

All folders are being watched by `Makefile`. If that is not a good idea make new folders...

```
./R
./tex
./Rmd
./figs
```

# Troubles with R/CYGWIN

I need an evironment variable `CYGWIN` where I set:

```
export CYGWIN='nodosfilewarning'
```

this is done by `wahaniMiscs::watch`
