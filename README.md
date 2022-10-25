# GiveBackMyTraces

GiveBackMyTraces let you discover those sneaky errors in ruby apps.

## Usage

Suppose you have the following code in your rails app:

```ruby
class ApplicationController < ActionController::Base
  rescue_from 'BaseError' do
    head 422
  end
end
```

After a huge refactoring or upgrade you may face some errors like:

```shell
❯ rspec spec/requests/my_action_spec.rb
F

Failures:

  1) MyActions GET /index returns http success
     Failure/Error: expect(response).to have_http_status(:success)
       expected the response to have a success status code (2xx) but it was 422
     # ./spec/requests/my_action_spec.rb:7:in `block (3 levels) in <top (required)>'

Finished in 0.07235 seconds (files took 0.80333 seconds to load)
1 example, 1 failure

....
```

And then to discover the real error you may need to start debugging to find the real issue.

Enter `give_back_my_traces`, just add in your Gemfile, eg:

```ruby
gem 'give_back_my_traces'
```

And add `GBMT.init` in your spec_helper:

```ruby
require 'give_back_my_traces'

RSpec.configure do |config|
  config.around(:each) do |example|
    GBMT.init(
      from: ENV.fetch("GBMT_BACKTRACE_FROM", Rails.root.to_s) # By default only print errors with a backtrace from your app
    )

    example.call

    GBMT.clear
    GBMT.stop
  end
```

And then you can see the errors running it with some GBMT envs:

```
GBMT_ENABLE=1 rspec spec/requests/my_action_spec.rb
----------------------------------------------------
 Error: BaseError
 Message: Test error
 Backtrace:
   /home/foo/projetos/test-gbmt/app/controllers/my_action_controller.rb:5:in `index'
   /home/foo/.rbenv/versions/3.0.4/lib/ruby/gems/3.0.0/gems/actionpack-7.0.4/lib/action_controller/metal/basic_implicit_render.rb:6:in `send_action'
   /home/foo/.rbenv/versions/3.0.4/lib/ruby/gems/3.0.0/gems/actionpack-7.0.4/lib/abstract_controller/base.rb:215:in `process_action'
   /home/foo/.rbenv/versions/3.0.4/lib/ruby/gems/3.0.0/gems/actionpack-7.0.4/lib/action_controller/metal/rendering.rb:53:in `process_action'
   /home/foo/.rbenv/versions/3.0.4/lib/ruby/gems/3.0.0/gems/actionpack-7.0.4/lib/abstract_controller/callbacks.rb:234:in `block in process_action'
   ...

```

Also you can filter erros by their backtrace with `GBMT_BACKTRACE_FROM`, it could be any string/regexp that matches the first line in the backtrace, eg:

`GBMT_ENABLE=1 GBMT_BACKTRACE_FROM='controllers/my_action_controller' rspec spec/requests/my_action_spec.rb`

See more in the examples folder.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/catks/give_back_my_traces.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
