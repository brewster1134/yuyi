class Maven < Yuyi::Roll
  dependencies :homebrew

  install do
    `brew install maven`
  end

  installed? do
    `brew list` =~ /maven/
  end
end
