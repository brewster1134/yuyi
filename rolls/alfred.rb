class Alfred < Yuyi::Roll
  dependencies :homebrew_cask

  install do
    `brew cask install alfred`
  end

  installed? do
    `brew cask list` =~ /alfred/
  end
end
