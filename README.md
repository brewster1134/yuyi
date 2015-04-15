[![gem version](https://badge.fury.io/rb/yuyi.svg)](https://rubygems.org/gems/yuyi)
[![dependencies](https://gemnasium.com/brewster1134/yuyi.svg)](https://gemnasium.com/brewster1134/yuyi)
[![docs](http://inch-ci.org/github/brewster1134/yuyi.svg?branch=master)](http://inch-ci.org/github/brewster1134/yuyi)
[![build](https://travis-ci.org/brewster1134/yuyi.svg?branch=master)](https://travis-ci.org/brewster1134/yuyi)
[![coverage](https://coveralls.io/repos/brewster1134/yuyi/badge.svg?branch=master)](https://coveralls.io/r/brewster1134/yuyi?branch=master)
[![code climate](https://codeclimate.com/github/brewster1134/yuyi/badges/gpa.svg)](https://codeclimate.com/github/brewster1134/yuyi)

[![omniref](https://www.omniref.com/github/brewster1134/yuyi.png)](https://www.omniref.com/github/brewster1134/yuyi)

# YUYI
Custom automation for installing/uninstalling/upgrading your local machine environment

---
#### Support
* OS X 10.9 (Mavericks)
* OS X 10.10 (Yosemite)

The only dependencies are already available by default on OS X

* Ruby
* Bash

---
#### Installation

_Fresh install of OS X?  Never installed ruby before?_
You will need to install yuyi with sudo. __You can have yuyi install an updated version of ruby :)__

```shell
sudo gem install yuyi
```

_Have ruby installed with `rbenv`, `rvm`, or via other means?_
You can just install yuyi normally

```shell
gem install yuyi
```

---
#### Menu
To create a yuyi menu files, run `yuyi init`. It will walk you through adding yuyi roll sources and rolls.

A yuyi menu consists of sources and rolls.  `Rolls` refer to individual things to install.  You can list them in any order, and Yuyi will make determine their dependencies and sure they are installed in the right order.

###### Example Menu
```yaml
sources:
  local: ~/Documents/Rolls
  yuyi: https://github.com/brewster1134/Yuyi-Rolls.git
rolls:
  google_chrome:
  ruby:
    versions: ['2.0.0-p353']
```

_Make sure to include a colon (:) at the end of each roll name._

If a roll accepts arguments, indent the key/value pairs below the roll name.  You will be prompted with roll options when Yuyi runs, and the opportunity to change them before anything is installed.

#### Running Yuyi
_Just run `yuyi`!_

```shell
yuyi
```
### Development
You can use yuyi to install it's own development dependencies __(so meta)__

```shell
git clone git@github.com:brewster1134/yuyi.git
cd yuyi
yuyi -m Yuyifile
bundle install
```

#### Running Tests
```shell
// run guard to watch the source files and automatically run tests when you make changes
bundle exec guard

// run rspec tests on the yuyi library
bundle exec rake yuyi:test

// run rspec tests on the rolls specified in a given menu
bundle exec rake yuyi:test:rolls

// run rspec tests on the library and the rolls
bundle exec rake yuyi:test:all
```

---
#### Writing Rolls
#### _required_
* `< Yuyu::Roll`  The roll class needs to inherit from Yuyi::Roll
* `install`       A block to install a roll
* `uninstall`     A block to uninstall a roll
* `upgrade`        A block to upgrade a roll
* `installed?`    A block to tests if your roll is already installed or not

#### _optional_
* `dependencies`  Declare dependencies (supports multiple arguments) that your roll depends on
* `options`       A hash of options (and a nested hash of option meta data _* see example below *_)

#### _available methods_
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
  options({
    :version => {
      :description => 'The specific version you would like to install',
      :example => '1.0',  # optional
      :default => '2.0',  # optional
      :required => true   # optional - shows option in red
    }
  })

  dependencies :homebrew, :foo

  install do
    dependencies :hombrew_cask if options[:version] == '2.0' # add dependencies conditionally
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
    run('brew list') =~ /myroll/
  end
end
```

[.](http://www.comedycentral.com/video-clips/3myds9/upright-citizens-brigade-sushi-chef)

[![WTFPL](http://www.wtfpl.net/wp-content/uploads/2012/12/wtfpl-badge-4.png)](http://www.wtfpl.net)
