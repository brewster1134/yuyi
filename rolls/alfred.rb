class Alfred < Yuyi::Roll
  dependencies :homebrew_cask

  install do
    run 'brew cask install alfred'
  end

  uninstall do
    run 'brew cask uninstall alfred'
  end

  update { install }

  installed? do
    `brew cask list` =~ /alfred/
  end
end
