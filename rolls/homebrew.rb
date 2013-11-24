class Homebrew < Yuyi::Roll
  title 'Homebrew'

  install do
    `ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go/install)"`
  end

  installed? do
    command? 'brew'
  end
end
