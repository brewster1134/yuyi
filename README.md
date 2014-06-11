![Travis CI](https://travis-ci.org/brewster1134/Yuyi.svg?branch=master)
# Yuyi
Opinionated automation for installing/uninstalling/upgrading your machine environment

###### Support
* Mac OS X

###### Dependencies
Nothing! Well thats not entirely true... the dependencies are already available by default on OS X
* Ruby >= 1.8.7
* Bash >= 3.2

#### Quick Usage
* Create a `yuyi_menu` file in your home folder _(see below for examples)_
* Run `ruby -e "$(curl -fsSL https://raw.github.com/brewster1134/Yuyi/master/bin/install)"` in Terminal

#### Example Menu

```yaml
sources:
  local: ~/Documents/Rolls
  yuyi: https://github.com/brewster1134/Yuyi-Rolls.git
rolls:
  google_chrome:
  ruby:
    versions: ['2.0.0-p353']
```

Make sure to include a colon (:) at the end of each roll name.

If a roll accepts arguments, indent the key/value pairs below the roll name.  You will be prompted with roll options when Yuyi runs, and the opportunity to change them before anything is installed.

### Development

##### Dependencies
* ruby
* bundler

##### Running Tests
Run tests using rspec through guard

```sh
bundle exec guard
```

##### Writing Rolls
###### _required_
* `< Yuyu::Roll`  The roll class needs to inherit from Yuyi::Roll
* `install`       A block to install a roll
* `uninstall`     A block to uninstall a roll
* `upgrade`        A block to upgrade a roll
* `installed?`    A block to tests if your roll is already installed or not

###### _optional_
* `dependencies`  Declare dependencies (supports multiple arguments) that your roll depends on
* `options`       A hash of options (and a nested hash of option meta data _* see example below *_)

###### _available methods_
* `title`             Returns a string of the roll title.
* `options`           Returns the roll options.
* `run`               This will run a system command.
    * `command` A string of the command you wish to run
    * `verbose` If true, will show formatted output & errors.  This is enabled when running yuyi with the `-V` or `--VERBOSE` flag
* `command?`          Returns true or false if a command succeeds or fails.  Good for using in the `installed?` block
* `write_to_file`     Will add lines of text to a file.  Good for using in the `install` block. Accepts multiple string arguments to be written as separate lines.
* `delete_from_file`  Will remove lines of text to a file.  Good for using in the `uninstall` block. Accepts multiple string arguments to be written as separate lines.

```ruby
class MyRoll < Yuyi::Roll
  install do
    run 'brew install my_roll', :verbose => true

    write_to_file '~/.bash_profile', "# #{title}"
  end

  uninstall do
    run 'brew uninstall my_roll'

    delete_from_file '~/.bash_profile', "# #{title}"
  end

  upgrade do
    run 'brew upgrade my_roll'
  end

  installed? do
    # simply check for a command
    command? 'brew'

    # or check the output of a command
    # using `run` will return true or false, so use
    `brew list` =~ /myroll/
  end

  dependencies :homebrew, :foo
  dependencies :hombrew_cask if options[:version] == '2.0' # add dependencies conditionally

  options(
    :version => {
      :description => 'The specific version you would like to install',
      :example => '1.0',  # optional
      :default => '2.0',  # optional
      :required => true   # optional - shows option in red
    }
  )
end
```

### TODO
* setup (post suite install tasks)
* write to file checks for existing lines
* Enforce required options
* New roll generator (use new!)
* DOCS!
* show roll options on -l
* home brew/home brew cask roll to inherit
* installation summary
* abort install if required options arent set
* post install commands

[.](http://www.comedycentral.com/video-clips/3myds9/upright-citizens-brigade-sushi-chef)
