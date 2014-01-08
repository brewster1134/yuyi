class HomebrewCask < Yuyi::Roll
  dependencies :homebrew

  install do
    run 'brew tap phinze/homebrew-cask'
    run 'brew install brew-cask'
  end

  uninstall do
    run 'brew untap phinze/homebrew-cask'
    run 'brew uninstall brew-cask'
  end

  update do
    say 'Updated via Homebrew', :type => :success, :indent => 6
  end

  installed? do
    !`brew cask`.empty?
  end
end
