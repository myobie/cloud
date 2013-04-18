So the goal here is to build a ruby framework for describing servers, their configs, and what needs to happen to get them setup.

# The end goal

    > kite check

... would print out any differences between the current config and the one in use.

    > kite migrate

... would resize servers, update configs, and run any deps on servers to migrate them to the new current config. This would refuse to do any destructive actions, but let you know how you can handle it manually.

    > kite ssh app1

... would ssh to that box.

# Principles

* I want to write ruby, not some weirdo dsl
* One can use yaml for some things, but it's not required and please don't overdo it
* I want my ruby code to actually resemble how my servers are setup
* My code should easily be able to generate a graph showing how all my boxes are connected and talking to each other

# Chef?

Well, right now, I'm trying to use babushka for the server deps. But, I'm not again using chef to setup each server. But I just don't like chef's syntax.