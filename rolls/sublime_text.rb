class SublimeText < Yuyi::Roll
  add_dependencies options[:version] == 2 ? :homebrew_cask : :homebrew_cask_versions

  available_options(
    :version => {
      :description => 'Specify between Sublime Text 2 or 3',
      :example => 3,
      :default => 3
    }
  )

  install do
    if options[:version] == 2
      `brew cask install sublime-text`
    else
      `brew cask install sublime-text-3`
    end
  end

  installed? do
    if options[:version] != 2
      `brew cask list` =~ /sublime-text3/
    else
      `brew cask list` =~ /sublime-text/
    end
  end
end
