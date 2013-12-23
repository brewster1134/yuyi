class HomebrewCask < Yuyi::Roll
  dependencies :homebrew

  install do
    `brew tap phinze/homebrew-cask`
    `brew install brew-cask`
  end

  installed? do
    !`brew cask`.empty?
  end
end
