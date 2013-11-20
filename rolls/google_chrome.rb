class GoogleChrome < Yuyi::Roll
  title 'Google Chrome'

  dependencies [
    :homebrew_cask
  ]

  install do
    `brew cask install google-chrome`
  end

  installed? do
    `brew cask list` =~ /google-chrome/
  end
end
