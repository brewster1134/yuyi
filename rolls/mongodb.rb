class Mongodb < Yuyi::Roll
  dependencies :homebrew

  install do
    run 'brew install mongodb'
  end

  update do
    run 'brew upgrade mongodb'
  end

  installed? do
    `brew list` =~ /mongodb/
  end
end
