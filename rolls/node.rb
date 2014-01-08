class Node < Yuyi::Roll
  dependencies :homebrew

  install do
    run 'brew install node'
  end

  uninstall do
    run 'brew uninstall node'
  end

  update do
    run 'brew upgrade maven'
  end

  installed? do
    `brew list` =~ /node/
  end
end
