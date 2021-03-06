# Lavigne

A custom formatter for Cucumber, designed to facilitate reporting and metrics collection.  By leveraging the [Avro](https://rubygems.org/gems/avro/versions/1.8.1) encoder file sizes are kept to a minimum, at the expense of human readability.

The result file format is designed to keep the memory footprint to a minimum. When writing, each feature is written and released from memory.  When reading features can be streamed one at a time from disk.

The intial schema is very much in flux.  It's not at all production ready.

Currently only supports Cucumber 2.4.
Even that may not work, there are zero tests currently ¯\_(ツ)_/¯

## File Schema
Lavigne result files are organized with one or more followed by feature records. The format is designed to be streamed from disk instead of loading it all into memory at once.  The *headers_end* record serves as a marker to easily separate results from metadata about the results.

|      __Record__     |     __Field__    | __Type__                                                 | __Required__ | __Notes__                                     |
|:-------------------:|:----------------:|----------------------------------------------------------|--------------|-----------------------------------------------|
| lavigne_record      | rec_type         | enum: feature, file_header, run_info,  kvp,  headers_end |       Y      |                                               |
|                     | data             | union: run_info, file_header, kvp_header, bytes          |       N      |                                               |
|                     |                  |                                                          |              |                                               |
| version_info_header | versions         | array: version_info                                      |       Y      |                                               |
|                     |                  |                                                          |              |                                               |
| version_info        | component        | string                                                   |       Y      |                                               |
|                     | version          | string                                                   |       Y      |                                               |
|                     |                  |                                                          |              |                                               |
| kvp_header          | name             | string                                                   |       Y      |                                               |
|                     | values           | array: kv_pair                                           |       Y      |                                               |
|                     |                  |                                                          |              |                                               |
| kv_pair             | name             | string                                                   |       Y      |                                               |
|                     | value            | string                                                   |       N      |                                               |
|                     |                  |                                                          |              |                                               |
| run_info            | run_info_version | long                                                     | Y            |                                               |
|                     | suite_id         | string                                                   | N            |                                               |
|                     | run_id           | string                                                   | Y            |                                               |
|                     | start_time       | long                                                     | Y            | epoch time                                    |
|                     | hostname         | string                                                   | N            |                                               |
|                     | owner_id         | string                                                   | N            |                                               |
|                     | team_id          | string                                                   | N            |                                               |
|                     | project_id       | string                                                   | N            |                                               |
|                     | env              | array: kv_pair                                           | N            |                                               |
|                     |                  |                                                          |              |                                               |
| feature             |                  |                                                          |              | See: avro/dsl/com/lavigne/cucumber/feature.rb |
|                     |                  |                                                          |              |                                               |


## Parsing a result file in Ruby
```ruby
# Open the file, read the headers and return
res_file = Lavigne::ResultFile.new(File.open('results.lav', 'rb'))

# Check the run info
if res_file.run_info.run_id == 'some.run.id'
	# Do something
end

# Work with raw binary feature data one at a time, feature will hold raw avro data
feature = res_file.next_feature

# Convert that raw data to a model
feature_model = Models::Cucumber::Feature.avro_raw_decode(value: feature)


# Work with expanded feature data one at a time, feature_model will hold a decoded feature
feature_model = res_file.next_feature_model

# Get all features at once
raw_features = res_file.features         # For raw
feature_models = res_file.feature_models # For models

# Iterate over features
res_file.each_feature { |feature| do_something(feature) }        # Raw
res_file.each_feature_model { |feature| do_something(feature) }  # Models
```



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
Lavigne.capture_env only: [ 'foo', 'bar' ]

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

