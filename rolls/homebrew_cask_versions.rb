class HomebrewCaskVersions < Yuyi::Roll
  dependencies :homebrew

  install do
    `brew tap caskroom/versions`
  end

  installed? do
    `brew tap` =~ /caskroom\/versions/
  end
end
