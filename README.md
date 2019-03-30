# YARD::Typedef

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/yard/typedef`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem


Installation
------------------------------------------------------------------------------

Add this line to your application's Gemfile:

```ruby
gem 'yard-typedef'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install yard-typedef


Usage
------------------------------------------------------------------------------

Enable the plugin in your `.yardopts` file by adding the line:

    --plugin yard-typedef

You can then use `@typedef` declaration tags and `@type:NAME` references in 
your doc-strings.


Development
------------------------------------------------------------------------------

Prerequisites:

1.  A supported version of Ruby installed. At the moment, that means `2.3.0` or
    or later.
    
2.  The [Bundler][] gem installed and it's `bundle` executable in your path.

[Bundler]: https://rubygems.org/gems/bundler

Check out the repo and open a terminal in it's directory.

The `master` branch is where development happens, and may be in a broken state.
If you are trying to fix a problem or add a feature to use you may want to work
off the tag of the version you are using.

In this case, create and switch to a branch from the appropriate version tag.
If you're using say version `0.1.0`, then you can do it with:

    $ git checkout -b "$(git config --get user.name)" v0.1.0

Which creates a new branch named after you (using your Git user name, you can
of course change that part to whatever you want) and switches to it.

After you're on the right branch, install the runtime and development
dependencies with Bundler. If you don't know how you like to do that, I
recommend:

    $ bundle install --path=./.bundle

You can then run the tests with

    $ rake

You can also run `bin/console` for an interactive prompt that will allow you to
experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `VERSION`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).


Contributing
------------------------------------------------------------------------------

Bug reports and pull requests are welcome on GitHub at
https://github.com/nrser/yard-typedef.

## License

The gem is available as open source under the terms of the
[BSD License](https://opensource.org/licenses/BSD-3-Clause) 'cause we west coast
like that.
