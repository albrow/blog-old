require 'pygments'
require 'fileutils'
require 'digest/md5'

PYGMENTS_CACHE_DIR = File.expand_path('../../_code_cache', __FILE__)
FileUtils.mkdir_p(PYGMENTS_CACHE_DIR)

module HighlightCode
  def highlight(str, lang)
    str = pygments(str, lang).match(/<pre>(.+)<\/pre>/m)[1].to_s.gsub(/\s*$/, '') #strip out divs <div class="highlight">
    table = '<div class="highlight"><table cellpadding="0" cellspacing="0"><tr><td class="gutter"><pre class="line-numbers">'
    code = ''
    str.lines.each_with_index do |line,index|
      table += "<span class='line'>#{index+1}</span>\n"
      code  += "<div class='line'>#{line}</div>"
    end
    table += "</pre></td><td class='code' width='100%'><pre><code class='#{lang}'>#{code}</code></pre></td></tr></table></div>"
  end

  def pygments(code, lang)
    if defined?(PYGMENTS_CACHE_DIR)
      path = File.join(PYGMENTS_CACHE_DIR, "#{lang}-#{Digest::MD5.hexdigest(code)}.html")
      if File.exist?(path)
        highlighted_code = File.read(path)
      else
        highlighted_code = Pygments.highlight(code, :lexer => lang, :formatter => 'html')
        File.open(path, 'w') {|f| f.print(highlighted_code) }
      end
    else
      highlighted_code = Pygments.highlight(code, :lexer => lang, :formatter => 'html')
    end
    highlighted_code
  end
end
