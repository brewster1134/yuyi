class HomebrewCaskVersions < Yuyi::Roll
  dependencies :homebrew

  install do
    run 'brew tap caskroom/versions'
  end

  update do
    say 'Updated via Homebrew', :type => :success, :indent => 6
  end

  installed? do
    `brew tap` =~ /caskroom\/versions/
  end
end
