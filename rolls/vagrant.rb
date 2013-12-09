class Vagrant < Yuyi::Roll
  dependencies [
    :homebrew_cask
  ]

  install do
    `brew cask install vagrant`
  end

  installed? do
    `brew cask list` =~ /vagrant/
  end
end
