class HomebrewCask < Yuyi::Roll
  title 'Homebrew Cask'
  dependencies [
    'homebrew'
  ]

  def install
    `brew tap phinze/homebrew-cask`
    `brew install brew-cask`
  end
end
