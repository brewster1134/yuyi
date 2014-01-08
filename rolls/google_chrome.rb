class GoogleChrome < Yuyi::Roll
  dependencies :homebrew_cask

  install do
    run 'brew cask install google-chrome'
  end

  uninstall do
    run 'brew cask uninstall google-chrome'
  end

  update { install }

  installed? do
    run 'brew cask list' =~ /google-chrome/
  end
end
