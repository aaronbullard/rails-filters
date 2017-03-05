# Filters
This is a helper class to translate a string of filters into usable sql to modify active record queries.

Example query:
 - `?filters=status==verified,age>18,weight>=<150;200`

This query translates to:
 - WHERE status = 'verified'
 - AND age > 18
 - AND weight BETWEEN 150 AND 200

## Usage
See the tests for usage and examples `/spec/filters_spec.rb`

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'filters'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install filters
```

<!-- ## Contributing
Contribution directions go here. -->

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
