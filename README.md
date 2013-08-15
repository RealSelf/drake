drake
=====
Simple web based deployment automation tool buit with [Sinatra](http://www.sinatrarb.com/).

Requirements
------------

* Ruby >= 1.9.3
* Redis (default 127.0.0.1:6379)

Run
---

```bash
$> git clone https://github.com/RealSelf/drake.git
$> cd drake
$> bundle install
$> cp config/drake.yml.example config/drake.yml
$> rackup
```

Config
------
Edit `config/drake.yml` with your Redis settings and deployment command. The deployment command string will be evaluated in the context of the deploy. 

Available variables:

- `@env` - environment
- `@tag` - tag being deployed
- `@name` - name of deployer
- `@start` - unix timestamp

Example:
```yaml
development:
  cmd: "cd /var/deploy; bundle exec cap deploy -s environment=<%= @env %> -s branch=<%= @tag %> -s deployed_by=<%= @name %>"
  redis: 
    host: 127.0.0.1
    port: 6379
    db: 0
production:
  cmd: "cd /var/deploy; bundle exec cap deploy -s environment=<%= @env %> -s branch=<%= @tag %> -s deployed_by=<%= @name %>"
  redis: 
    host: 123.123.1.123
    port: 6379
    db: 3
```

Test
----

```bash
$> cd drake
$> rspec --format documentation
```

Copyright
---------

Copyright © 2013 RealSelf, Inc. See [LICENSE](https://github.com/RealSelf/drake/blob/master/LICENSE) for details.
