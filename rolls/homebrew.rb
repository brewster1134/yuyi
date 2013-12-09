class Homebrew < Yuyi::Roll
  install do
    `ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go/install)"`
  end

  installed? do
    command? 'brew'
  end
end
