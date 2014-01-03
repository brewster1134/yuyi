class Maven < Yuyi::Roll
  dependencies :homebrew

  install do
    run 'brew install maven'
  end

  update do
    run 'brew upgrade maven'
  end

  installed? do
    `brew list` =~ /maven/
  end
end
