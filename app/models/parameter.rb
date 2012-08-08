class Parameter < ActiveRecord::Base

  CONTENT_TYPES = ['html', 'text', 'string', 'number']

  validates :content_type, :inclusion => {:in => CONTENT_TYPES}
  validates :content_type, :key, :description, :presence => true

  def self.[](key)
    self.find_by_key(key)
  end
end
