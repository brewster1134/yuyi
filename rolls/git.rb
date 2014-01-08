class Git < Yuyi::Roll
  dependencies :homebrew

  install do
    run 'brew install git'
  end

  uninstall do
    run 'brew uninstall git'
  end

  update do
    run 'brew upgrade git'
  end

  installed? do
    `brew list` =~ /git/
  end
end
