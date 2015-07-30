## Hubot GF

Hubot GF teams up with [Hubot](https://github.com/github/hubot) to perform tasks. Because she runs in a Rails app,
Hubot GF has more potential than Hubot and together they can be very powerful.

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
gem 'hubotgf'
```

Mount the Hubot GF routes inside of your `routes.rb`. Hubot will contact this route when it receives a command that it
can't understand:

```ruby
mount HubotGf::Engine => '/hubotgf'
```

Add Hubot scripts - this is the only time you will have to touch the Hubot Coffeescript files. After this, it's all Ruby.

Messenging API:

```coffee
module.exports = (robot) ->

  robot.router.post '/hubot/pm', (req, res) ->
    data = req.body
    robot.reply user: data.replyTo, "#{data.message}"
    res.end ""

  robot.router.post '/hubot/room', (req, res) ->
    data = req.body
    robot.messageRoom data.room, "#{data.message}"
    res.end ""
```

Respond script to offload unknown commands to Hubot GF.

```coffee
module.exports = (robot) ->

  robot.respond /(.*)/i, (msg) ->
    params =
      _sender: msg.message.user.jid
      _room: msg.message.room
      command: msg.message.text

    params = JSON.stringify(params)

    msg.http('YOUR_HUBOT_GF_SERVER/hubotgf/tasks')
      .headers('Accept': 'application/json', 'Content-Type': 'application/json')
      .post(params) (err, response, body) ->
        if err then msg.send "Error contacting my GF"
```

### Configuration

```ruby
HubotGf.configure do |config|
  # :sidekiq or :resque, if set to nothing then the worker will run inline
  config.performer = :sidekiq

  # base URL for Hubot, so that Hubot GF can contact Hubot via HTTP to respond to messages
  config.hubot_url = 'http://your-hubot.herokuapp.com'

  # catchall worker that is performed when no workers listen for the command. This worker should
  # include HubotGf::Worker and respond to `call`, which is passed the command given
  config.catchall_worker = nil

  # can be any lambda/proc that accepts these 3 arguments. This closure will be executed
  # whenever a new worker is started. Most likely you will not need to edit this, see the
  # source code for the actual implementation. The first two arguments are the sender and room name
  config.perform = lambda do |worker, args|
    worker.new.perform(*args)
  end

end
```

The `perform` proc will be set to enqueue a Sidekiq/Resque worker based on the `performer` configuration option.
If no performer is set, the worker will simply be instantiated as shown.

### Creating a worker

A worker is any class that includes `HubotGf::Worker`. Commands are defined via `listen`, which accepts a regular
expression and a method name. The captures from the regex are sent as arguments to the method when the worker is started.

```ruby
class TestWorker
  include HubotGf::Worker

  listen /Make (.*) a (.*)/i => :make
  listen /Give me a (.*)/i => :give

  def make!(who, what)
    # ...
  end

  def give(what)
    # ...
  end

end
```

Hubot will now execute `make` when it receives a message such as "Make me a pizza" and `give` when it receives
a message like "Give me a cookie".

### Sending feedback

Workers have access to `@sender` and `@room`, which return the sender ID and room ID (respectively) where the command was sent. You
can send messages back to Hubot using any of three commands:

- `reply(message)` will send the message back wherever it came from (through PM if it came directly, back to the room if it came from a room)
- `pm(message)` will send back to the sender directly
- `broadcast(message)` will send back to the room it was sent from

```ruby
class TestWorker
  include HubotGf::Worker

  listen /Make (*.*) a (.*)/i => :make!

  def make!(who, what)
    broadcast "Made #{who} a #{what}"
    reply "Completed your request!"
  end

end
```

Because of this asynchronous communication, Hubot doesn't care about the workload, it simply sends and receives messages.
The heavy lifting is done by the server, most likely on a background job.

### Contribute

As of now we've only built HubotGf to work with the [Hipchat adapter](https://github.com/hipchat/hubot-hipchat)
(reason we use JID) but we plan to add more adapters in the future. We'll hopefully add the `hubotgf_adapter_name.coffee`
to [hubot-scripts](https://github.com/github/hubot-scripts). Feel free to submit a pull request and we'll try to add
to your code in.
