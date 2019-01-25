# Crossbeams::Layout

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/crossbeams/layout`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'crossbeams-layout'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install crossbeams-layout

## Usage

Basic example:

```ruby
layout = Crossbeams::Layout::Page.build(rules) do |page|
  page.section do |section|
    section.add_caption 'Main'
    section.add_text 'An explanation'
    section.show_border!
  end

  page.form_object ui_rule.form_object
  page.form_values form_values
  page.form_errors form_errors
  page.form do |form|
    form.action '/path/to/save_form'
    form.remote!
    form.add_field :a_field
  end

  page.row do |row|
    row.col do |col|
      col.add_text 'Some minor heading', wrapper: :h2
    end
    row.col do |col|
      col.add_text 'Some other text', wrapper: :p
    end
  end
end

# In a view:
layout.add_csrf_tag(csrf_tag) # (if csrf used in forms)
layout.render
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/crossbeams-layout.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

