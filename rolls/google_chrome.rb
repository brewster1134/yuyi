class GoogleChrome < Yuyi::Roll
  dependencies :homebrew_cask

  install do
    run 'brew cask install google-chrome'
  end

  installed? do
    run 'brew cask list' =~ /google-chrome/
  end
end
