%SCL Undergraduate Thesis/Research Project Document Class File v1.1.2 (2016/06/06)
%adapted from NCSU thesis/dissertation template
%Send comments, questions to John Justine S. Villar <john_justine.villar@upd.edu.ph>

% Intro Options
\ProvidesClass{scl-ug-manuscript}
\NeedsTeXFormat{LaTeX2e}
\DeclareOption*{%
  \PassOptionsToClass{\CurrentOption}{report}
}
\ProcessOptions\relax
\LoadClass[12pt,a4paper]{report}

\typeout{SCL Undergraduate Thesis/Research Paper Manuscript Style Ver. 2016/06/06  by JJSVillar}

\usepackage{multicol,graphicx,amsmath}
\usepackage[left=1.5in, right=1in,top=1.25in,bottom=1in]{geometry}

\emergencystretch=.5em

% Define a null command for comments
\long\def\comment#1{}

\comment{

  Example of using the thesis option:
    \documentclass[scl-mansucript]{report}
    \begin{document}
    \title{How to Write Theses\\
        With Two Line Titles}
    \author{Juan dela Cruz}

    \beforepreface

    \chapter*{Preface}
        This thesis tells you all you need to know about...
    \chapter*{Acknowledgements}
        I would like to thank...

    \tableofcontents
    \listoftables
    \listoffigures

    \addchapter*{List of Symbols}
    \begin{tabbing}
         ...

    \afterpreface

    \chapter{Introduction}
         ...
    \chapter{Conclusions}
         ...

    \bibliographystyle{plain}
    \bibliography{mybib}

    \appendix
    \chapter{A Long Proof}
         ...
    \chapter{And Another One}
         ...
    \end{document}

Documentation:
    This option
      - sets the margins and interline spacing
      - disallows page breaks at hyphens
      - modifies figure captions to be \bf and \protect'ed
      - allows line breaks in multiple citations
      - formats the title page and produces a copyright page (optionally)
      - Changes title of the bibliography to ``References''

    The \beforepreface command creates the title page, the certification page
    and a copyright page (optionally).  Then the user should put preface section(s),
    using the \chapter*{section title} command, followed by
    the desired tables of contents (e.g., \tableofcontents,
    \listoftables, \listoffigures).  Additional preface sections (such
    as a list of symbols) can be included after the tables of
    contents--use \addchapter*{section title} for these sections to
    include them in the table of contents.  The \afterpreface command
    then sets things up to start the main body (on arabic page 1).

    The following commands can control what goes in the front matter
    material:

    for the title and certification pages:
    \title{thesis title}
    \author{author's name}
    \thesistype{e.g., research project, bachelor's thesis}
        - Undergraduate Research Paper if omitted
    \degree{e.g., Bachelor of Science}
        - Bachelor of Science in Computer Science if omitted
    \specialization{e.g.,Bioinformatics}
        - optional
    \adviser{author's adviser}
    \chairman{department chair}
    \dept{author's department/institute}
        - Department of Computer Science if omitted
    \college{author's college/unit}
        - College of Engineering if omitted
    \university{university name}
        - University of the Philippines if omitted
    \location{location of university}
        - Diliman, Quezon City
    \submitdate{month year in which submitted}
        - date LaTeX'd if omitted
    for the copyright page:
    \copyrightyear{year degree conferred (next year if submitted in Dec.)}
        - year LaTeX'd (or next year, in December) if omitted
    \copyrighttrue or \copyrightfalse
        - produce or don't produce a copyright page (false by default)
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\makeatletter
% We need 1" margins for whitespace (i.e., to where page numbers or
% headers begin) except on the binding edge, where it is 1 1/2"
%\oddsidemargin 0.25in \textwidth 6.25in \topmargin 0.00in
%\textheight 8.50in

% Disallow page breaks at hyphens (this will give some underfull vbox's,
% so an alternative is to use \brokenpenalty=100 and manually search
% for and fix such page breaks)
\brokenpenalty=10000

% For some environments we switch back to single-spacing, also
% provide \dsp in case you need double-spacing where single-spacing
% is otherwise used.
\def\ssp{\def\baselinestretch{1.00}\large\normalsize}
\def\dsp{\def\baselinestretch{1.40}\large\normalsize}
\def\csp{\def\baselinestretch{1.10}\large\normalsize}

% To allow running page footers:
\def\leftfoot#1{\gdef\@leftfoot{#1}}
\def\rightfoot#1{\gdef\@rightfoot{#1}}

% Default initialization of footers:
\def\@leftfoot{}\def\@rightfoot{}

% Plain page style (modified version from `report.sty')
%   - modify \@oddfoot to contain footer information:
\def\ps@plain{\let\@mkboth\@gobbletwo
	\def\@oddhead{}%
	\def\@oddfoot{\rm\makebox[.4\linewidth][l]\@leftfoot%
		\hfil\thepage\hfil\makebox[.4\linewidth][r]\@rightfoot}%
	\def\@evenhead{}\let\@evenfoot\@oddfoot}

% Running headers (modified version from `report.sty'):
%   - do not force running headers to uppercase
%   - modify \@oddfoot and \@evenfoot to contain footer information
%     (if two-sided, reverse left and right footers on even numbered pages):
\if@twoside \def\ps@headings{\let\@mkboth\markboth
	\def\@oddfoot{\rm\@leftfoot\hfil\@rightfoot}%
	\def\@evenfoot{\rm\@rightfoot\hfil\@leftfoot}%
	\def\@evenhead{\sl \thepage\hfil \sc \leftmark}
	\def\@oddhead{\hbox{}\sc \rightmark \hfil \rm\thepage}
	\def\chaptermark##1{\markboth {\ifnum \c@secnumdepth >\m@ne \sc\@chapapp\ \thechapter. \ \fi ##1}{}}
	\def\sectionmark##1{\markright {\ifnum \c@secnumdepth >\z@
			\thesection. \ \fi ##1}}}
\else \def\ps@headings{\let\@mkboth\markboth
	\def\@oddfoot{\rm\@leftfoot\hfil\@rightfoot}%
	\def\@evenfoot{}
	\def\@oddhead{\hbox {}\sc \rightmark \hfil \rm\thepage}
	\def\chaptermark##1{\markright {\ifnum \c@secnumdepth >\m@ne \sc\@chapapp\ \thechapter. \ \fi  ##1}}}
\fi
\def\ps@myheadings{\let\@mkboth\@gobbletwo
	\def\@oddhead{\hbox{}\sl\rightmark \hfil \rm\thepage}
	\def\@oddfoot{}\def\@evenhead{\rm \thepage\hfil\sc\leftmark\hbox{}}
	\def\@evenfoot{}\def\sectionmark##1{}\def\subsectionmark##1{}}

% Floating Environments (modified version from `latex.tex'):
%   - sets floats (e.g., figures and tables) to be single spaced
%\def\@xfloat#1[#2]{\ifhmode \@bsphack\@floatpenalty -\@Mii\else
%   \@floatpenalty-\@Miii\fi\def\@captype{#1}\ifinner
%      \@parmoderr\@floatpenalty\z@
%    \else\@next\@currbox\@freelist{\@tempcnta\csname ftype@#1\endcsname
%       \multiply\@tempcnta\@xxxii\advance\@tempcnta\sixt@@n
%       \@tfor \@tempa :=#2\do
%                        {\if\@tempa h\advance\@tempcnta \@ne\fi
%                         \if\@tempa t\advance\@tempcnta \tw@\fi
%                         \if\@tempa b\advance\@tempcnta 4\relax\fi
%                         \if\@tempa p\advance\@tempcnta 8\relax\fi
%         }\global\count\@currbox\@tempcnta}\@fltovf\fi
%    \global\setbox\@currbox\vbox\bgroup
%    \ssp\@normalsize                    % this line added
%    \boxmaxdepth\z@
%    \hsize\columnwidth \@parboxrestore}

% Footnotes (modified version from `latex.tex'):
%   - sets footnotes to be single spaced
\long\def\@footnotetext#1{\insert\footins{\ssp\footnotesize % added \ssp
		\interlinepenalty\interfootnotelinepenalty
		\splittopskip\footnotesep
		\splitmaxdepth \dp\strutbox \floatingpenalty \@MM
		\hsize\columnwidth \@parboxrestore
		\edef\@currentlabel{\csname p@footnote\endcsname\@thefnmark}\@makefntext
		{\rule{\z@}{\footnotesep}\ignorespaces
			#1\strut}}}

% Captions (modified version from `report.sty'):
%   - put the figure number in boldface
%   - protect the caption
\long\def\@makecaption#1#2{\protect         % added \protect
	\vskip 10pt
	\setbox\@tempboxa\hbox{{\bf #1}: #2}           % added {\bf ...}
	\ifdim \wd\@tempboxa >\hsize \unhbox\@tempboxa\par \else \hbox
	to\hsize{\hfil\box\@tempboxa\hfil}
	\fi}

% a version of itemize that has no space between the items
\renewenvironment{itemize}{\begin{list}{$\bullet$}
		{\setlength{\rightmargin}{\leftmargin}
			\setlength{\itemsep}{0em}
			\setlength{\topsep}{0em}
			\setlength{\parsep}{0em}}}{\end{list}}

% like the default itemize (i.e., extra space between items)
\newenvironment{bigitemize}{\begin{list}{$\bullet$}
		{\setlength{\rightmargin}{\leftmargin}}}{\end{list}}

%***************************************************************************************************
%***** To make the captions centered and dotted leaders for chapter
%***************************************************************************************************
\def\@chapnum{\ \thechapter}

% Modified the following so that "Chapter," "Appendix," or whatever appears
% before the number in the table of contents.  

\def\@chapter[#1]#2{
	\refstepcounter{chapter}
	\typeout{\thechapter}
	\addcontentsline{toc}{chapter}
	{\protect\bf\numberline{\thechapter}\hspace{-0.9pt}#1}
	\chaptermark{#1}
	\addtocontents{lof}{\protect\addvspace{12pt}}
	\addtocontents{lot}{\protect\addvspace{12pt}} \if@twocolumn
	\@topnewpage[\@makechapterhead{#2}]
	\else \@makechapterhead{#2}
	\@afterheading \fi}

% Modified \@makechapterhead to allow multi-line chapter titles.  Automatic
% linebreaking is turned off because lines are to be broken for grammatical
% sense, not for line filling purposes.

\def\@makechapterhead#1{{ \parindent 0pt
		\ifnum \c@secnumdepth >\m@ne
		% \lnspc{1.25}
		\LARGE\bf\centerline{\@chapapp{}\@chapnum}
		\par
		\vskip 15pt
		\fi
		\begingroup
		\setbox\@tempboxa\hbox{\begin{tabular}{c} \LARGE\bf #1\end{tabular}}
		\ifdim \wd\@tempboxa >\hsize
		\errmessage{Chapter title needs to have linebreaks (\noexpand\\)
			inserted by the author}
		\begin{tabular}{c} \LARGE\bf #1\end{tabular}
		\else \hbox to\hsize{\hfil\box\@tempboxa\hfil}
		\fi
		\endgroup
		\nobreak \vskip 38pt } }


\def\@makeschapterhead#1{{ \parindent 0pt
		\normalfont\LARGE\bf\centerline{#1}\par
		\nobreak \vskip 40pt } }

\def\l@chapter#1#2{\addpenalty{-\@highpenalty}
	\vskip 1.0em plus 1pt \@tempdima 1.5em
	\begingroup
	\parindent \z@ \rightskip \@pnumwidth
	\parfillskip -\@pnumwidth %\bf\ifboldmathon\protect\boldmath\fi
	\leavevmode \advance\leftskip\@tempdima \hskip -\leftskip #1\nobreak
	\leaders\hbox{$\m@th \mkern \@dotsep mu.\mkern \@dotsep mu$}\hfill
	\nobreak\hbox to\@pnumwidth{\hss #2}\par
	\penalty\@highpenalty \endgroup}

%\def\l@section{\@dottedtocline{1}{3em}{2.3em}}
%\def\l@subsection{\@dottedtocline{2}{5.3em}{3.2em}}
%\def\l@subsubsection{\@dottedtocline{3}{8.5em}{4.1em}}
%\def\l@paragraph{\@dottedtocline{4}{11.5em}{5em}}
%\def\l@subparagraph{\@dottedtocline{5}{13.5em}{6em}}
%********************************************************************************************************
%*****  End of this part
%*****           (To make the captions centered and dotted leaders for chapter)
%********************************************************************************************************
% Thebibliography (modified version from `report.sty'):
%   - change the title to `List of References'
%   - go ahead and add it to the table of contents
\def\thebibliography#1{\chapter*{List of References\@mkboth
		{List of References}{List of References}}
	\addcontentsline{toc}{chapter}{\bf List of References}
	\list{[\arabic{enumi}]}{\settowidth\labelwidth{[#1]}\leftmargin\labelwidth
		\advance\leftmargin\labelsep
		\usecounter{enumi}}
	\def\newblock{\hskip .11em plus .33em minus -.07em}
	\sloppy\clubpenalty4000\widowpenalty4000
	\sfcode`\.=1000\relax}
\let\endthebibliography=\endlist

% Table of Contents (modified version from `report.sty'):
%   - change the title to `Table of Contents'
%   - change to single space
\def\tableofcontents{\@restonecolfalse\if@twocolumn\@restonecoltrue\onecolumn
	\fi\chapter*{Table of Contents\@mkboth
		{Table of Contents}{Table of Contents}}
	{\@starttoc{toc}}\if@restonecol\twocolumn\fi}

% List of Figures (modified version from `report.sty'):
%   - change to single space
%   - add to table of contents
\def\listoffigures{\@restonecolfalse\if@twocolumn\@restonecoltrue\onecolumn
	\fi\chapter*{List of Figures\@mkboth
		{List of Figures}{List of Figures}}{\@starttoc{lof}}\if@restonecol\twocolumn
	\fi\addcontentsline{toc}{chapter}{\bf List of Figures}}

% List of Tables (modified version from `report.sty'):
%   - change to single space
%   - add to table of contents
\def\listoftables{\@restonecolfalse\if@twocolumn\@restonecoltrue\onecolumn
	\fi\chapter*{List of Tables\@mkboth
		{List of Tables}{List of Tables}}{\dsp\@starttoc{lot}}\if@restonecol\twocolumn
	\fi\addcontentsline{toc}{chapter}{\bf List of Tables}}

% Citations (modified version from `latex.tex'):
%   - add space between multiple citations
%   - do not box citations

\def\@citex[#1]#2{\if@filesw\immediate\write\@auxout{\string\citation{#2}}\fi
	\def\@citea{}\@cite{\@for\@citeb:=#2\do
		{\@citea\def\@citea{, }\@ifundefined        % added space after `,'
			{b@\@citeb}{{\bf ?}\@warning
				{Citation `\@citeb' on page \thepage \space undefined}}%
			{\csname b@\@citeb\endcsname}}}{#1}}            % removed the \hbox


% Chapter Headings setting
\renewcommand{\@makechapterhead}[1]{%
	\vspace*{-30\p@}%
	\renewcommand{\baselinestretch}{1.2} 
	\vspace*{.15in}
	{\parindent \z@ \raggedright \normalfont
		\ifnum \c@secnumdepth >\m@ne
		\LARGE\bfseries \@chapapp\space \thechapter
		\par\nobreak
		\vskip 15\p@
		%\vskip 1in
		\fi
		\interlinepenalty\@M
		\huge \bfseries #1\par\nobreak
		\vskip 50\p@
		\renewcommand{\baselinestretch}{1.5} 
		%\vskip 20\p@
}}

\let\appendixold\appendix
\renewcommand{\appendix}{
	%	\usepackage{tocloft}
	\appendixold
	\csp\clearpage
	\addcontentsline{toc}{chapter}{\bf Appendix}
	\makeatletter
	\addtocontents{toc}{%
		\protect\setcounter{tocdepth}{1}
		\let\string\bfdefault\string\mddefault
		\let\protect\l@chapter\protect\l@section
		\let\protect\l@section\protect\l@subsection
	}
	\makeatother
	
	\setcounter{table}{0}
	\renewcommand{\thetable}{\Alph{chapter}\arabic{table}}
	\renewcommand{\thefigure}{\Alph{chapter}\arabic{figure}}
}

%

\newcommand*{\textoverline}[1]{$\overline{\hbox{#1}}\m@th$}


% \author and \title are defined in report;
% here are the rest of the front matter defining macros
\def\displaytitle#1{\gdef\@displaytitle{#1}}
\def\authorone#1{\gdef\@authorone{#1}}
\def\authortwo#1{\gdef\@authortwo{#1}}
\def\authorthree#1{\gdef\@authorthree{#1}}
\def\lab#1{\gdef\@lab{#1}}
\def\dept#1{\gdef\@dept{#1}}
\def\college#1{\gdef\@college{#1}}
\def\university#1{\gdef\@university{#1}}
\def\location#1{\gdef\@location{#1}}
\def\thesistype#1{\gdef\@thesistype{#1}}
\def\thesisdocument#1{\gdef\@thesisdocument{#1}}
\def\degree#1{\gdef\@degree{#1}}
\def\specialization#1{\gdef\@specialization{#1}}
\def\submitday#1{\gdef\@submitday{#1}}
\def\submitmonth#1{\gdef\@submitmonth{#1}}
\def\submityear#1{\gdef\@submityear{#1}}
\def\adviser#1{\gdef\@adviser{#1}}
\def\advisertwo#1{\gdef\@advisertwo{#1}}
\def\adviserthree#1{\gdef\@adviserthree{#1}}
\def\deptone#1{\gdef\@deptone{#1}}
\def\depttwo#1{\gdef\@depttwo{#1}}
\def\deptthree#1{\gdef\@deptthree{#1}}
\def\coreader#1{\gdef\@coreader{#1}}
\def\deptchair#1{\gdef\@deptchair{#1}}
\def\dean#1{\gdef\@dean{#1}}
\def\copyrightyear#1{\gdef\@copyrightyear{#1}}
\long\def\abstractpage#1{\gdef\@abstractpage{#1}}
\long\def\acknowledgements#1{\gdef\@acknowledgements{#1}}
\def\defensedate#1{\gdef\@defensedate{#1}}

\def\@title{ }
\def\@displaytitle{\@title}
\def\@author{ }
\def\@authorone{ }
\def\@authortwo{ }
\def\@authorthree{ }
\def\@adviser{ }
\def\@advisertwo{ }
\def\@adviserthree{ }
\def\@deptone{ }
\def\@depttwo{ }
\def\@deptthree{ }
\def\@deptchair{ }
\def\@lab{Scientific Computing Laboratory}
\def\@dept{Department of Computer Science}
\def\@college{College of Engineering}
\def\@university{University of the Philippines}
\def\@thesistype{Undergraduate Research Paper}
\def\@specialization{ }
\def\@location{Diliman, Quezon City}
\def\@degree{Bachelor of Science in Computer Science}
\def\@abstractpage{ }
\def\@acknowledge{ }
\def\@defensedate{ }
\def\@submityear{ }
\def\@submitmonth{\ifcase\the\month\or
  January\or February\or March\or April\or May\or June\or
  July\or August\or September\or October\or November\or December\fi
  \space \number\the\year}
\def\@submitday{ }
% December theses should have the next year as the copyright year
\ifnum\month=12
    \@tempcnta=\year \advance\@tempcnta by 1
    \edef\@copyrightyear{\number\the\@tempcnta}
\else
    \def\@copyrightyear{\number\the\year}
\fi

\newif\ifspecialize \specializefalse
\newif\iftwoauthors \twoauthorsfalse
\newif\ifthreeauthors \threeauthorsfalse
\newif\iftwoadvisers\twoadvisersfalse
\newif\ifthreeadvisers\threeadvisersfalse
\newif\ifdiffaffiliations\diffaffiliationsfalse
\newif\ifcopyright \copyrightfalse
\newif\ifacknowledgments\acknowledgmentsfalse





\newsavebox\TBox
\def\textoverline#1{\savebox\TBox{#1}%
	\makebox[0pt][l]{#1}\rule[1.2\ht\TBox]{\wd\TBox}{0.4pt}}

\def\titlep{%
\thispagestyle{empty}%
\vspace{-0.25in}
\begin{center} 
\includegraphics[height=1.75cm,width=1.75cm]{uplogo.png}\\
{\sc\uppercase\expandafter {\@university}}
\vfill\vfill\ssp
{\sc \@degree}
\vfill\vfill\vfill\csp
{\large\sc\iftwoauthors{\@authorone\ and \@authortwo}\else\ifthreeauthors{\@authorone, \@authortwo,\\ and \@authorthree}\else{\@authorone}\fi\fi}   
\vfill\vfill  
\dsp
{\ifx\@displaytitle\empty{\dsp\bf \Large\expandafter{\@title}}
	\else{\bf \Large\expandafter{\@displaytitle}}\fi}\\
\vfill\vfill\vfill
\csp
{\ifdiffaffiliations{
\iftwoadvisers{
\begin{tabular}{c}Adviser:\\{\small\bf\sc\@adviser}\\\small \@deptone\\ \@university\end{tabular}
\hfill
\begin{tabular}{c}Co-Adviser:\\ {\small\bf\sc\@advisertwo}\\ \small\@depttwo\\ \@university\end{tabular}
}
\else\ifthreeadvisers{
\begin{tabular}{c}Adviser:\\{\small\bf\sc\@adviser}\\\small \@deptone\\ \@university\end{tabular}
\hfill
\begin{tabular}{c}Co-Adviser:\\ {\small\bf\sc\@advisertwo}\\ \small\@depttwo\\ \@university\end{tabular}
\vfill
\begin{center}Co-Adviser:\\ {\small\bf\sc\@advisertwo}\\ \small\@depttwo\\ \@university\end{center}
}
\else{Adviser:\\{\small\bf\sc\@adviser}\\ \small\@dept\\ \@university}
\fi
\fi}
\else{
\iftwoadvisers{
\begin{tabular}{c}Adviser:\\{\small\bf\sc\@adviser}\\\small \@deptone\\ \@university\end{tabular}
\hfill
\begin{tabular}{c}Co-Adviser:\\ {\small\bf\sc\@advisertwo}\\ \small\@depttwo\\ \@university\end{tabular}}
\else\ifthreeadvisers{
\begin{tabular}{c}Adviser:\\{\small\bf\sc\@adviser}\\\small \@deptone\\ \@university\end{tabular}
\hfill
\begin{tabular}{c}Co-Adviser:\\ {\small\bf\sc\@advisertwo}\\ \small\@depttwo\\ \@university\end{tabular}
\vfill
\begin{center}Co-Adviser:\\ {\small\bf\sc\@advisertwo}\\ \small\@depttwo\\ \@university\end{center}}
\else{Adviser:\\{\bf\sc\@adviser}\\ \@dept\\ \@university}
\fi
\fi
}
\fi}
\vfill\vfill\vfill
{\@submitmonth\ \@submityear}\\
\vfill
Thesis Classification:\\
\textbf{F}\\This \@thesistype\ is available to the public.
\end{center}
\newpage}



\def\univpermissionpage{%			
\null\vspace{-0.5in}\vfill
\vfill
{\it\noindent``{\iftwoauthors{We}\else\ifthreeauthors{We}\else{I}\fi\fi} hereby grant the University of the Philippines a non-exclusive, worldwide, royalty-free license to reproduce, publish and publicly distribute copies of this \lowercase\expandafter{\@thesistype}\ in whatever form subject to the provisions of applicable laws, the provisions of the UP IPR policy and any contractual obligations, as well as more specific permission marking on the Title Page."\\

\noindent``Specifically, {\iftwoauthors{we}\else\ifthreeauthors{we}\else{I}\fi\fi} grant the following rights to the University:
\begin{enumerate}
\item [a)] To upload a copy of the work in the theses database of the
college/school/institute/ department and in any other databases
available on the public internet;
\item[b)] To publish the work in the college/school/institute/department
journal, both in print and electronic or digital format and online; and
\item [c)] To give open access to above-mentioned work, thus allowing ``fair
use" of the work in accordance with the provisions of the Intellectual
Property Code of the Philippines (Republic Act No. 8293), especially
for teaching, scholarly and research purposes."
\end{enumerate}}
\vspace{0.7in}
\begin{flushright}
\iftwoauthors{\sc \@authorone\ / \@authortwo}
\else\ifthreeauthors{\sc\@authorone\ / \@authortwo\ / \@authorthree}
\else{\sc \@authorone}
\fi
\fi\\
Date of Submission: \@submitmonth\ \@submityear
\end{flushright}
\vfill
\newpage}


\def\certification{%
\dsp%
\begin{center} 
{\bf\csp\@dept\\\@college\\\@university\\\@location}
\vfill
{\bf ENDORSEMENT}
\end{center}
\vspace{0.5in}
\noindent This {\lowercase\expandafter{\@thesistype}} hereto attached, entitled {\bf \@title}, prepared and submitted by{     \iftwoauthors{\textbf{\@authorone}\ and \textbf{\@authortwo}}\else\ifthreeauthors{\textbf{\@authorone}, \textbf{\@authortwo}\ and \textbf{\@authorthree}}\else{\textbf{\@authorone}}\fi\fi}, in partial fulfillment of the requirement for the degree of {\bf\@degree}, is hereby accepted.
\vfill
\iftwoadvisers{\begin{center}\ssp\begin{tabular}{c}{\bf \sc \@adviser}\\Adviser\end{tabular}
\hfill\begin{tabular}{c}{\bf \sc \@advisertwo}\\
Co-Adviser\end{tabular}\end{center}}
\else\ifthreeadvisers{\begin{center}\ssp\begin{tabular}{c}{\bf \sc \@adviser}\\Adviser\end{tabular}
\hfill\begin{tabular}{c}{\bf \sc \@advisertwo}\\
Co-Adviser\end{tabular}\end{center}
\vspace{0.25in}
\begin{center}\ssp{\bf \sc \@adviserthree}\\ Co-Adviser\end{center}}
\else{\hfill\ssp\begin{tabular}{r}{\bf \sc \@adviser}\\ Adviser\end{tabular}}
\fi
\fi
\vfill
\dsp
\noindent This {\lowercase\expandafter{\@thesistype}} is hereby officially accepted and approved as partial
fulfillment of the requirements for the degree of {\bf\@degree}.
\vfill
\hfill\ssp
\begin{tabular}{r}\dsp
\qquad \qquad {\bf \sc \@deptchair}\\
\qquad \qquad Chair\\\qquad \qquad {\@dept}\ssp
\end{tabular}
\vfill
\newpage}

\def\copyrightpage{%
\null
\vfill\dsp
{\iftwoauthors{We}\else\ifthreeauthors{We}\else{I}\fi\fi} hereby declare that {\iftwoauthors{we}\else\ifthreeauthors{we}\else{I}\fi\fi} have created this work completely on
{\iftwoauthors{our}\else\ifthreeauthors{our}\else{I}\fi\fi} own and used no other sources or tools than the ones listed, and that 
{\iftwoauthors{we}\else\ifthreeauthors{we}\else{I}\fi\fi} have marked any citations accordingly.\\\csp
\vspace{0.7in}
\csp
\begin{flushright}
{\sc\iftwoauthors{\@authorone\ / \@authortwo}\else\ifthreeauthors{\@authorone\ / \@authortwo\ / \@authorthree}\else{\@authorone}\fi\fi}\\
\@location\\
\@submitmonth\ \@submityear
\end{flushright}
\vspace{0.7in}
\newpage}


%\def\publicationpage{%
%\thispagestyle{empty}\ssp
%\begin{center}
%\includegraphics[height=1.6cm,width=1.6cm]{uplogo}\\
%{\small \uppercase\expandafter{\@university}}
%\vfill
%{\small \@degree}\\
%\vfill
%{\sc
%\iftwoauthors{\small \@authorone\ and \@authortwo}
%\else\ifthreeauthors{\small \@authorone, \@authortwo\ and \@authorthree}
%\else{\small \@authorone}
%\fi
%\fi 
%}
%\vfill
%{\ifx\@displaytitle\empty{\bf \expandafter{\@title}}
%\else{\bf\expandafter{\@displaytitle}}\fi}
%\vfill
%{\small\ifdiffaffiliations{
%\iftwoadvisers{
%\small Adviser:\\{\small\bf\sc\@adviser}\\\small \@deptone\\ \@university
%\vfill
%\small Co-Adviser:\\ {\small\bf\sc\@advisertwo}\\ \small\@depttwo\\ \@university
%}
%\else\ifthreeadvisers{
%\small Adviser:\\ {\small\bf\sc\@adviser}\\ \small\@deptone\\ \@university
%\vfill
%\small Co-Adviser:\\{\small\bf\sc\@advisertwo}\\ \small\@depttwo\\ \@university
%\vfill
%\small Co-Adviser:\\{\small\bf\sc\@adviserthree}\\ \small\@deptthree\\ \@university
%}
%\else{\small Adviser:\\{\small\bf\sc\@adviser}\\ \small\@dept\\ \@university}
%\fi
%\fi}
%\else{
%\iftwoadvisers{
%Adviser:\\{\bf\sc\@adviser}\\ \@dept\\ \@university
%\vfill
%Co-Adviser:\\ {\bf\sc\@advisertwo}\\\@dept\\ \@university
%}
%\else\ifthreeadvisers{
%Adviser:\\ {\bf\sc\@adviser}\\ \@dept\\ \@university
%\vfill
%Co-Adviser:\\{\bf\sc\@advisertwo}\\  \@dept\\ \@university
%\vfill
%Co-Adviser:\\{\bf\sc\@adviserthree}\\ \@dept\\ \@university
%}
%\else{Adviser:\\{\bf\sc\@adviser}\\ \@dept\\ \@university}
%\fi
%\fi
%}
%\fi}
%
%\vfill
%%\begin{center}
%{\small Date of Submission:\\
%{\@submitmonth\ \@submityear}
%\vfill
%\@thesistype Classification:\\
%\textbf{F}\\
%This {\lowercase\@thesistype} is available to the public.}\\
%\vfill
%\vspace{0.6in}
%\iftwoauthors{
%\underline{\small\sc \@authorone\ / \@authortwo}\\\small Students}
%\else\ifthreeauthors{
%\underline{\small\sc \@authorone\ / \@authortwo\ / \@authorthree}\\\small Students
%}
%\else{
%\underline{\small\sc \@authorone}\\\small Student}
%\fi
%\fi
%
%\vspace{0.4in}
%
%\iftwoadvisers{\underline{\small \sc\@adviser\ / \@advisertwo}\\\small Advisers}
%\else\ifthreeadvisers{\underline{\small \sc\@adviser\ / \@advisertwo\ / \@adviserthree}\\\small Advisers}
%\else{\underline{\small \sc\@adviser}\\\small Adviser}
%\fi
%\fi
%\end{center}
%\newpage
%}


\def\ackpage{%
\chapter*{Acknowledgments}  
\dsp
\@acknowledgements
\addcontentsline{toc}{chapter}{\bf Acknowledgments}
}



\def\abspage{
\chapter*{Abstract}
\begin{center}{\large \bf \@displaytitle}\end{center}
\bigskip
\ssp
\fontsize{12}{12}
\noindent
\begin{tabular}{ll}
\begin{minipage}[t]{0.5\textwidth}
 \iftwoauthors{\@authorone\\\@authortwo}
 \else\ifthreeauthors{\@authorone\\\@authortwo\\\@authorthree}
 \else{\@authorone}
 \fi
 \fi  
\\University of the Philippines, \@submityear
\end{minipage} & 
\begin{minipage}[t]{0.45\textwidth}
\iftwoadvisers{Adviser:\\\@adviser\\Co-Adviser:\\\@advisertwo}
\else\ifthreeadvisers{Adviser:\\\@adviser\\Co-Adviser:\\\@advisertwo\\Co-Adviser:\\\@adviserthree}
\else{Adviser:\\\@adviser}
\fi
\fi
\end{minipage}
\end{tabular}

\vspace{0.5in}
\dsp
\@abstractpage 
\addcontentsline{toc}{chapter}{\bf Abstract}
}



\def\beforepreface{%
	\pagenumbering{roman}
	\pagestyle{plain}
	\titlep
	\univpermissionpage
	\certification
	\ifcopyright\copyrightpage\fi
	\abspage
	\tableofcontents
	\newpage
	\ifacknowledgments\ackpage\fi
	}

\def\addchapter*#1{%
    \chapter*{#1}
    \addcontentsline{toc}{chapter}{#1}}

\def\afterpreface{\newpage
    \pagenumbering{arabic}
    \pagestyle{headings}}

% Start with pagestyle{headings} in case front matter isn't processed
\pagestyle{headings}

% Make the thesis double-spaced
\dsp

\makeatother

%Copyright (c) 2016 by John Justine S. Villar <john_justine.villar@upd.edu.ph>

%This work may be distributed and/or modified under the conditions of the LaTeX Project Public License (LPPL), either version 1.3c of this license or (at your option) any later version.  The latest version of this license is in the file:
%
% http://www.latex-project.org/lppl.txt
%
% This work is "maintained" (as per LPPL maintenance status).
%
% end of scl-ug-manuscript.sty
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
