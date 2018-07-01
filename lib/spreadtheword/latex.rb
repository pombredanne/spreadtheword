require 'nokogiri'

class Spreadtheword::LaTeX
  def initialize title, author, topics, getTranslation
    @title = title
    @author = author
    @topics = topics
    @getTranslation = getTranslation
  end

  def write!
    puts %Q_
% !TEX TS-program = pdflatex
% !TEX encoding = UTF-8 Unicode

\\documentclass[11pt]{article} % use larger type; default would be 10pt

\\usepackage[utf8]{inputenc} % set input encoding (not needed with XeLaTeX)
\\usepackage{geometry} % to change the page dimensions
\\geometry{a4paper} % or letterpaper (US) or a5paper or....
\\usepackage{graphicx} % support the \\includegraphics command and options
\\usepackage{booktabs} % for much better looking tables
\\usepackage{array} % for better arrays (eg matrices) in maths
\\usepackage{paralist} % very flexible & customisable lists (eg. enumerate/itemize, etc.)
\\usepackage{verbatim} % adds environment for commenting out blocks of text & for better verbatim
\\usepackage{subfig} % make it possible to include more than one captioned figure/table in a single float
\\usepackage{fancyhdr} % This should be set AFTER setting up the page geometry
\\pagestyle{fancy} % options: empty , plain , fancy
\\renewcommand{\\headrulewidth}{0pt} % customise the layout...
\\lhead{}\\chead{}\\rhead{}
\\lfoot{}\\cfoot{\\thepage}\\rfoot{}
\\usepackage[nottoc,notlof,notlot]{tocbibind} % Put the bibliography in the ToC
\\usepackage[titles,subfigure]{tocloft} % Alter the style of the Table of Contents
\\renewcommand{\\cftsecfont}{\\rmfamily\\mdseries\\upshape}
\\renewcommand{\\cftsecpagefont}{\\rmfamily\\mdseries\\upshape} % No bold!
\\title{#{@title}}
\\author{#{@author}}
\\begin{document}
\\maketitle
#{sections}
\\end{document}
    _
  end

  def sections
    ret = ''
binding.pry
    @topics.each do |k,v|
      next if k.nil?
      first = v[0]
      title = k
      description = ''
      url = ''
      if :gitlab == first[:origin]
        title = first[:title]
        description = first[:payload].description
        url = first[:payload].web_url
      end
      ret += %Q_
\\section{#{escape title}}

#{escape description}

#{escape url}
      _
    end
    if @topics[nil]
      ret += %Q_
\\section{Others}
      _
    end
    ret
  end

  def escape str
    return '' unless str.present?
    if @getTranslation && str =~ Spreadtheword::NONASCII
      str = @getTranslation.call(str)
    end
    str.gsub(Spreadtheword::NONASCII, '').gsub('\\', '\\textbackslash ').gsub('&', '\\\&').gsub('%', '\\%').gsub('$', '\\$').gsub('#', '\\#').gsub('_', '\\_').gsub('{', '\\{').gsub('}', '\\}').gsub('~', '\\textasciitilde ').gsub('^', '\\textasciicircum ')
  end
end
