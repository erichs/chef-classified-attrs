classified-attrs Cookbook
=========================
This cookbook provides a library routine for loading Ruby hash data into the Node attribute hash in such a way that attributes are available with minimal fuss to recipes at run-time, but are not saved to the server at the end of a chef-run.

Why do this?
------------

Perhaps you'd like to store your sensitive configuration data somewhere other than on the Chef server (via an encrypted data bag, Chef Vault, etc.) Perhaps you would like to query a key-value store, or perform your own sensitive Ohai-like automated attribute gathering. This library assists by providing a general mechanism to load your data.

Usage
-----
#### classified-attrs::default
Include `classified-attrs` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[classified-attrs]"
  ]
}
```

Let's assume you have a JSON file, ```/tmp/data.json``` that contains data you'd like to load into @node for use in your recipes:

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
    :key => node['sensitive_key']
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
