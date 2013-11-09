class Homebrew < Yuyi::Roll
  title 'Homebrew'

  def install
    `ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)"`
  end
end
