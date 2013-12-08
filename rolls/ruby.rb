class Ruby < Yuyi::Roll
  RUBY_VERSION_REGEX = /([0-9]+\.[0-9]+\.[0-9]+-p[0-9]+)/
  AVAIL_VERSIONS = `rbenv install -l`.scan(RUBY_VERSION_REGEX).flatten
  INSTALLED_VERSIONS = `rbenv versions`.scan(RUBY_VERSION_REGEX).flatten

  title 'Ruby'

  dependencies [
    :rbenv
  ]

  available_options({
    :versions => {
      :description => 'An array of ruby versions you would like to install',
      :example => [AVAIL_VERSIONS.last],
      :default => AVAIL_VERSIONS.last
    }
  })

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
