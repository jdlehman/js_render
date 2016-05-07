$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'js_render'

def clean_heredoc_html(str)
  str.gsub(/\n$/, '').gsub(/>\s+</, '><').strip
end
