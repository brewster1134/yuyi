# Yuyi
Opinionated automation for setting up a new machine.

### Support
* Mac OS X

### Dependencies
Nothing!

Well thats not entirely true... the dependencies are already available on OS X
* Ruby >= 1.8.7
* Bash >= 3.2

### Customizing
Yuyi looks for a `menu.yml` file at the root of the project.  Prefix each roll file name with a `-`.

If a roll accepts arguments, place a `:` at the end, and indent the `key: value` below it.

```yaml
- roll_name
- roll_name_with_options:
    stuff: pok
```

### Instructions
Run the binary

`./bin/fire`

##### Arguments

* `-v` Version

### Development
To contribute to Yuyi...

* Fork the repo
* Run `bundle install`
* Run `bundle exec rspec` to run the tests
* Issue a pull request

##### Rolls
Each roll represents a single addition to be installed.

_REQUIRED_
* `< Yuyu::Roll`  The roll class needs to inherit from Yuyi::Roll
* `title`         A nice friendly title for what is to be installed
* `install`       A method that runs whatever is needed

_OPTIONAL_
* `dependencies`  An array of other roll file names

```ruby
class MyRoll < Yuyi::Roll
  title 'My Custom Roll'
  dependencies [
    :ruby
  ]

  def install
    `brew install my_roll`
  end
end
```

[.](http://www.comedycentral.com/video-clips/3myds9/upright-citizens-brigade-sushi-chef)
