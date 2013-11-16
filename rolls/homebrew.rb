class Homebrew < Yuyi::Roll
  title 'Homebrew'

  install do
    `ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)"`
  end
end
