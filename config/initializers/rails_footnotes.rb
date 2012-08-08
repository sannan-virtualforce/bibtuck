if defined?(Footnotes) && Rails.env.development?
  Footnotes.run! # first of all
  Footnotes::Filter.prefix = 'mvim://open?url=file://%s&amp;line=%d&amp;column=%d'
end
