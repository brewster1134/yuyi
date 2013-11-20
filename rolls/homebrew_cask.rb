class HomebrewCask < Yuyi::Roll
  title 'Homebrew Cask'

  dependencies [
    :homebrew
  ]

  install do
    `brew tap phinze/homebrew-cask`
    `brew install brew-cask`
  end

  installed? do
    !`brew cask`.empty?
  end
end
