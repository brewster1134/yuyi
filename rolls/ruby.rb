class Ruby < Yuyi::Roll
  RUBY_VERSION_REGEX = /([0-9]+\.[0-9]+\.[0-9]+-p[0-9]+)/
  AVAIL_VERSIONS = `rbenv install -l`.scan(RUBY_VERSION_REGEX).flatten
  INSTALLED_VERSIONS = `rbenv versions`.scan(RUBY_VERSION_REGEX).flatten

  title 'Ruby'

  dependencies [
    :rbenv
  ]

  install do
    # Collect versions from options and make sure they are available through rbenv
    versions = (options[:versions] || []).select{ |v| AVAIL_VERSIONS.include? v }

    # Install the last available version if none specified were available
    versions << AVAIL_VERSIONS.last if versions.empty?

    versions.each do |v|
      `rbenv install #{v}` unless INSTALLED_VERSIONS.include? v
    end
  end

  installed? do
    (options[:versions] || []).all?{ |v| INSTALLED_VERSIONS.include? v }
  end
end
