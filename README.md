# Yuyi
Opinionated automation for setting up a new machine.

###### Support
* Mac OS X

###### Dependencies
Nothing! Well thats not entirely true... the dependencies are already available by default on OS X
* Ruby >= 1.8.7
* Bash >= 3.2

#### Quick Usage
* Create a `menu.yml` file in your Documents folder _(see below for examples)_
* Run `ruby -e "$(curl -fsSL https://raw.github.com/brewster1134/Yuyi/master/bin/install)"` in Terminal

#### Example Menu

```yaml
google_chrome:
ruby:
  versions: ['2.0.0-p353']
```

Make sure to include a colon (:) at the end of each roll name.

If a roll accepts arguments, indent the key/value pairs below the roll name.  You will be prompted with roll options when Yuyi runs, and the opportunity to change them before anything is installed.

### Development

##### Dependencies
* rspec

##### Writing Rolls
###### _required_
* `< Yuyu::Roll`  The roll class needs to inherit from Yuyi::Roll
* `install`       A block with your installation isntructions

###### _optional_
* `dependencies`      Static dependencies (comma separated symbols) that your roll depends on
* `add_dependencies`    Dynamic dependencies (comma separated symbols) that your roll may depend on given certain conditions
* `installed?`        A block that tests if your roll is already installed or not (must return nil or false)
* `available_options` A hash of options (and a nested hash of option meta data _* see example below *_)

```ruby
class MyRoll < Yuyi::Roll
  dependencies :homebrew

  add_dependencies :hombrew_cask if options[:version] == '2.0'

  available_options(
    :version => {
      :description => 'The specific version you would like to install',
      :example => '1.0', # optional
      :default => '2.0' # optional
      :required => true # optional - shows option in red
    }
  )

  install do
    `brew install my_roll`
  end

  installed? do
    `brew list` =~ /myroll/
  end
end
```

### TODO
* Enforce required options
* New roll generator
* Install script interacts with /bin/fire arguments
* Roll specific optional `uninstall` method

[.](http://www.comedycentral.com/video-clips/3myds9/upright-citizens-brigade-sushi-chef)
