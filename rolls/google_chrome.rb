class GoogleChrome < Yuyi::Roll
  title 'Google Chrome'
  dependencies [
    :homebrew_cask
  ]

  def install
    `brew cask install google-chrome`
  end
end
