class CategorySize
  MAPPING = YAML.load_file(File.join(Rails.root, 'config', 'category_sizes.yml'))

  def self.all
    MAPPING.map { |category, size| size }.flatten.compact.map(&:to_s).sort
  end

  def self.get(category)
    if category.nil?
      return all
    end

    MAPPING[category.name] || MAPPING['default']
  end

  def self.all_grouped
    grouped = {'Other' => [['n/a', 'n/a']]}
    MAPPING.each do |category, sizes|
      case category
      when 'default'
        category_name = 'Clothes'
      else
        category_name = category.split.each { |word| word.capitalize! }.join(' ')
      end
      grouped[category_name] = sizes if sizes.length > 1
    end
    grouped
  end

end
