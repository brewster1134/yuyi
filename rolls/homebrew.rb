class Homebrew < Yuyi::Roll
  title 'Homebrew'

  install do
    `ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)"`
  end

  installed? do
    !`brew`.empty?
  end
end
