class HipChat < Yuyi::Roll
  dependencies :homebrew_cask

  install do
    run 'brew cask install hipchat'
  end

  installed? do
    `brew cask list` =~ /hipchat/
  end
end
