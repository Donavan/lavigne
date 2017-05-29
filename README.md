# Lavigne

A custom formatter for Cucumber, designed to facilitate reporting and metrics collection.  By leveraging the [Avro](https://rubygems.org/gems/avro/versions/1.8.1) encoder file sizes are kept to a minimum, at the expense of human readability.

The result file format is designed to keep the memory footprint to a minimum. When writing, each feature is written and released from memory.  When reading features can be streamed one at a time from disk.

The intial schema is very much in flux.  It's not at all production ready.

Currently only supports Cucumber 2.4.
Even that may not work, there are zero tests currently ¯\_(ツ)_/¯

## File Schema
A lavigne result file contains discrete records that are either a header record or a feature.  Header records have a type attribute for categorization with the special *headers_end* header type indicating the end of the headers section.

* file_header - Contains version information for Lavgine, Ruby and Cucumber.
* run_info - Contains details about the run, and the enviroment
* kvp - Key value pair headers allow for collection of data by the test developer.

Features each adhere to the schema provided by various Cucumber shims. Theses will be available as distinct schema files later for now you can save the results from 
```ruby
Lavigne._instance_for(::Cucumber::VERSION).json_schema
```

The schema for each Cumber shim is intended to be a compatible with the json formatter output for features.  If you have code that can parse a Cucumber json file you're most of the way to using Lavigne.

See the implementation of Lavigne::ResultFile for details on parsing this format.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'lavigne'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install lavigne

## Usage

### Capture Metadata about your run
```ruby
# See avro/dsl/lavigne_common.rb:run_info_v1 for details on all fields
# start_time, and hostname are popoulated automatically
Lavigne.include_run_info( { 'suite_id' => 'SUITE_ID' , 'run_id' => 'RUN_ID' })

```

### Capture Enviroment Variables
```ruby
# Grab all env vars
Lavigne.capture_env

# Grab only certain env vars
Lavigne.capture_env only: [ 'foo', 'bar ]

# Grab all env vars except secrets
Lavigne.capture_env except: [ 'secret1', 'secret2' ]
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/lavigne. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

