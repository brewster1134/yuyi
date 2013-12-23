class Git < Yuyi::Roll
  dependencies :homebrew

  install do
    `brew install git`
  end

  installed? do
    `brew list` =~ /git/
  end
end
