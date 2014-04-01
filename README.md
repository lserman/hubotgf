## Hubot GF

Hubot GF teams up with Hubot to perform tasks. Because she runs in a Rails app, Hubot GF can be much more powerful 
than Hubot and together they can be very powerful.

### Why

I noticed that devs didn't care to write custom Hubot scripts when we launched Hubot with our team. I started Hubot GF to 
make Hubot scripting a little easier:

- Devs are more comfortable with Ruby than Coffee (or JS)
- Devs are more comfortable inside a Rails app than a Node app
- Deploying new Rails code was something built into our process, Node was not
- Things are easier in Ruby (HTTP, SSH, etc)

With Hubot GF, devs don't need to edit Hubot scripts at all. The commands are defined within any Rails app that includes 
the Hubot GF engine.

### Installing Hubot GF

Add to your Gemfile and bundle:

```
gem 'hubotgf', github: 'lserman/hubotgf'
```

Mount the Hubot GF routes inside of your `routes.rb`. Hubot will contact this route when it receives a command that it 
can't understand:
```ruby
mount HubotGf::Engine => '/hubotgf'
```

### Configuration

```ruby
HubotGf.configure do |config|
  # :sidekiq or :resque, if set to nothing then the worker will run inline
  config.performer = :sidekiq
  
  # base URL for Hubot, so that Hubot GF can contact Hubot via HTTP to respond to messages
  config.hubot_url = 'http://your-hubot.herokuapp.com'
  
  # can be any lambda/proc that accepts these 3 arguments. This closure will be executed
  # whenever a new worker is started. Most likely you will not need to edit this, see the 
  # source code for the actual implementation.
  config.perform = lambda do |worker, args, metadata = {}| 
    worker.new.perform(*args)
  end
  
end
```

The `perform` proc will be set to enqueue a Sidekiq/Resque worker based on the `performer` configuration option. If no performer is set, the worker will simply be instantiated as shown. The `metadata` hash contains information from Hubot, such as the `:sender` (JID of the user) and `:room` (room name the command was sent from).

The default proc will append the `sender` and `room` arguments to the `args` array according to the worker method's arity (explained further below)

### Creating a worker

A worker is any class that responds to `perform` and includes `HubotGf::Worker`. This convention is spawned from the popular background job processors Sidekiq and Resque.

Commands are defined as regular expressions, and each match is passed into `perform`. The `sender` and `room` argument can be optionally accepted into `perform`. If the `perform` method does not accept those two arguments, then they will simply not be sent.

```ruby
class TestWorker
  include HubotGf::Worker
  
  self.command = /Make (*.*) a (.*)/i
  
  def perform(who, what, sender, room)
    p "Made #{who} a #{what} from #{sender} (sent to room: #{room})"
  end
  
end
```

Hubot will now execute this method when it receives a message such as "Make me a pizza".

### Sending feedback

Workers have access to the `gf` object, which has two methods: `pm` and `room`. These methods can be used to send messages back to Hubot and inform people when their job is done and what it returned.

```ruby
class TestWorker
  include HubotGf::Worker
  
  self.command = /Make (*.*) a (.*)/i
  
  def perform(who, what, sender, room)
    gf.room(room, "Made #{who} a #{what}")
    gf.pm(sender, "Completed your request!")
  end
  
end
```

Because of this asynchronous communication, Hubot doesn't care about the workload, it simply sends and receives messages. The heavy lifting is done by the server, most likely on a background job.
