class Vagrant < Yuyi::Roll
  dependencies :homebrew_cask

  install do
    run 'brew cask install vagrant'
  end

  uninstall do
    run 'brew cask uninstall vagrant'
  end

  update { install }

  installed? do
    `brew cask list` =~ /vagrant/
  end
end
