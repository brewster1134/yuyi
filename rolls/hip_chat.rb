class HipChat < Yuyi::Roll
  dependencies :homebrew_cask

  install do
    run 'brew cask install hipchat'
  end

  uninstall do
    run 'brew cask uninstall hipchat'
  end

  update { install }

  installed? do
    `brew cask list` =~ /hipchat/
  end
end
