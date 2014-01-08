class Imagemagick < Yuyi::Roll
  dependencies :homebrew

  install do
    run 'brew install imagemagick'
  end

  uninstall do
    run 'brew uninstall imagemagick'
  end

  update do
    run 'brew update imagemagick'
  end

  installed? do
    `brew list` =~ /imagemagick/
  end
end
