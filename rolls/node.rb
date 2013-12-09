class Node < Yuyi::Roll
  dependencies [
    :homebrew
  ]

  install do
    `brew install node`
  end

  installed? do
    `brew list` =~ /node/
  end
end
