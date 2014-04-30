classified-attrs Cookbook
=========================
This cookbook implements a library mechanism for loading attributes into Chef's
override_attributes hash for the duration of a chef run, but without the side effect of
saving those attributes to the node at the completion of a chef run.

Why do this?
------------

Perhaps you'd like to store your sensitive configuration data somewhere other than on the Chef server (via an encrypted data bag, Chef Vault, etc.) Maybe you have sensitive data pre-baked into your image. Perhaps you would like to query a key-value store, or perform your own sensitive Ohai-like automated attribute gathering. This library assists by providing a general mechanism to load your sensitive data.

Usage
-----
#### include_recipe "classified-attrs"
At the top of your recipe that references a classified attribute, do:

```ruby
include_recipe "classified-attrs" 
```

Let's assume you have a JSON file, ```/tmp/data.json``` that contains data you'd like to load into ```node``` for use in your recipes:

```json
{
  "sensitive_key": "sekret data"
}
```

Load and use that data with recipe code like:

```ruby
load_secrets(JSON.parse(File.read '/tmp/data.json'))

resource "do something" do
  ...
  variables({
    :key => node["sensitive_key"]
  })
end
```

Contributing
------------
1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
Author: Erich Smith, 2014

Based on [irccloud/blacklist-node-attrs](https://github.com/irccloud/blacklist-node-attrs)
