class Imagemagick < Yuyi::Roll
  dependencies :homebrew

  install do
    run 'brew install imagemagick'
  end

  installed? do
    `brew list` =~ /imagemagick/
  end
end
