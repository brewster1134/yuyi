class Homebrew < Yuyi::Roll
  install do
    run 'ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go/install)"'
  end

  update do
    run 'brew update'
  end

  installed? do
    command? 'brew'
  end
end
