class Rbenv < Yuyi::Roll
  title 'rbenv'

  dependencies [
    :homebrew
  ]

  install do
    `brew install rbenv ruby-build`
    write_to_file '~/.bash_profile', 'eval "$(rbenv init -)"'
    if on_the_menu? :zsh
      write_to_file '~/.zshrc', 'eval "$(rbenv init -)"'
    end
  end

  installed? do
    `brew list` =~ /rbenv/ && `brew list` =~ /ruby-build/
  end
end
