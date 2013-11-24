class Rbenv < Yuyi::Roll
  title 'rbenv'

  dependencies [
    :homebrew
  ]

  install do
    # Remove RVM
    `rvm implode` if command? 'rvm'

    # Install
    `brew install rbenv ruby-build`

    # Add initialization to shell
    write_to_file '~/.bash_profile', "# #{title}", 'eval "$(rbenv init -)"'
    if on_the_menu? :zsh
      write_to_file '~/.zshrc', "# #{title}", 'eval "$(rbenv init -)"'
    end
  end

  installed? do
    command?('rbenv') && `brew list` =~ /rbenv/ && `brew list` =~ /ruby-build/
  end
end
