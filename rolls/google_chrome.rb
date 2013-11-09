class GoogleChrome < Yuyi::Roll
  title 'Google Chrome'
  dependencies [
    'homebrew_cask'
  ]

  def install
    Yuyi.say 'INSTALLLLL'
    # `brew cask install google-chrome`
  end
end
