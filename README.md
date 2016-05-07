# JsRender

**Disclaimer: This is currently a "work in progress". More functionality, improvements, and docs are coming. Use at your own risk**

JsRender is an unopinionated Ruby library for rendering JavaScript "components" on the server side. This approach works with [React](https://facebook.github.io/react/), [Angular](ihttps://angular.io/), [Ember](http://emberjs.com/), or any other library of your choice. The only requirement is that there is a JavaScript function that returns HTML for the component or view such that it can be properly rendered on the server side (e.g. [`ReactDOMServer.renderToString`](https://facebook.github.io/react/docs/top-level-api.html#reactdomserver.rendertostring) in React).

The library works in two essential parts:
- Calls a JavaScript function (defined by the user) that returns HTML. This allows us to render our JS component/view when the page initially loads, rather than having the delay of doing it solely on the client side.
- Optionally calls a JavaScript function on the client (also defined by the user) that does any initialization that needs to happen on the client side. This generally will initialize the existing component HTML that has been rendered with the library of choice to make it interactive and attach behaviors.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'js_render'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install js_render

## Usage

### Rendering a component

You can render a component like:

```erb
<div>
  <%= render_component 'TodoList', {items: ['Build a gem', 'Add docs']} %>
</div>
```

`render_component` takes 2 arguments, a String `component_name` and `data`, which is either a JSON String or an Object that responds to `to_json`.

#### What happens under the hood

After calling `render_component` here is what happens:

**Initial Server Render**

- find a file named `TodoList.js` in the path `app/assets/javascripts/**/*`
  - if this file contains a function named `window.renderTodoListServer`, it will call it, passing to it the JSON data as an argument. the result of the function should be an HTML string
  - the result of the function is wrapped in a span tag with a unique ID
  - finally the HTML is inserted inline into our template and be rendered with the initial server render

This takes care of the initial server render of our component. You can configure the suffix of the component lookup from `.js`, the lookup paths, and the name of the server render function. Check out the configuration section below.

**Client Side Render**

The other thing that happens when you call `render_component` is that a script tag is rendered inline. The script tag calls a function, `window.renderTodoListClient`, that takes the unique ID of the span the component has been rendered in, and the JSON data as arguments. The client render function can handle any initialization that needs to happen after the server render. JsRender expects this function to already be in scope by the time the script tag is called. Putting this in the user's hands prevents duplication of any library code and allows the user to expose the framework as well as the client render functions in whatever way they choose and that works best in their JS setup/build process. (that said this is a desired place for improvement in the future for JsRender)

You can configure the name of the client render function. Check out the configuration section below.

### With Rails

JsRender exposes its methods as view helper methods via a Railtie.

### Plain old Ruby

You will need to instantiate a `JsRender::Renderer` to call JsRender methods with.

```ruby
renderer = JsRender::Renderer.new(component_name, data)
renderer.render_component
```

### Configuration

Configuration settings can be modified within the `JsRender.configure` block. Or set directly off of `JsRender.config`

```ruby
JsRender.configure do |config|
  config.base_path = 'app/assets/javascripts/components'
  config.component_paths = ['/**/*.js']
end

JsRender.config.base_path = 'app/assets/javascripts'
JsRender.config.base_path = ['/components/*.js', '/legacy_components/**/*.js']
```

#### Options

**use_asset_pipeline**

Indicate if you want Rails asset pipeline to handle your component files. This will take care of any pre-processing for you (like if your asset pipeline is compiling CoffeeScript or ES2015/ES6 code for you). If you are not using JsRender with Rails, this setting will not do anything.
Defalts to `false`

**base_path**

This is the base path where your components live.
Defaults to `app/assets/javascripts`

**component_paths**

These are the paths off of your base path that are searched to find your component (or more accurately your components' server render functions). Wildcards are supported.

If you are using Rails AND the asset pipeline, the lookup path can point to your pre-built file and the asset pipeline will give JsRender the built file. If you are using another build tool, make sure you are pointing to the built assets. JsRender will NOT take care of any compile step for you, it expects these files to already be compiled to ES5 compatible with [ExecJS](https://github.com/rails/execjs).
Defaults to `['/**/*']`

**component_suffix**

This is the suffix that is added to your component name. It functions as a regex string when looking up your render `"#{component_name}#{component_suffix}"`.

If your component structure is a folder named after your component with an `index.js` file, you can do something like `/renderer.js` to find a specific file within your folder. Or if your component and server render function are in different files you could do something like `/(index|serverRenderer).js`. The regex aspect is also useful if you need a wildcard to match a hash in the file name (generated by your build tool potentially).
Defaults to '.js'

**server_render_function**

This is the name of the function that is called to render your component on the server. It receives the JSON data as an argument and returns a string of HTML that is rendered inline.

If you want the component name to be included in the name dynamically, you can use a `*` to denote where the component name is inserted into the function.
Defaults to `window.render*Server` (eg for `MyComponent`, `window.renderMyComponentServer`)

**client_render_function**

This is the name of the function that is called to render your component on the client (which may just be initialization since it was already rendered by the server). It receives the unique ID of the span that the component was rendered in initially as well as the JSON data as arguments.

If you want the component name to be included in the name dynamically, you can use a `*` to denote where the component name is inserted into the function.
Defaults to `window.render*Client` (eg for `MyComponent`, `window.renderMyComponentClient`)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jdlehman/js_render. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Motivation and Thanks

This project came out of the desire to support server side rendering of React components. The most popular existing solution, [`react-rails`](https://github.com/reactjs/react-rails) is much more opinionated, but also does a lot implicitly under the hood. If your focus is on React server side rendering, and your experience primarily lies in Ruby on Rails, or you do not mind writing your JavaScript within the boundaries and opinions of react-rails, I highly recommend you take a look at it. Another good React/Rails specific library for server side React rendering to check out is [react_on_rails](https://github.com/shakacode/react_on_rails). Many thanks to the contributors of these projects as they were both influential in creating JsRender.

The goal of this project is to be framework agnostic and support server side rendering for any JavaScript component library, popular or self-rolled. While Rails support is baked in, the ultimate goal of this project is to work anywhere where Ruby is used as the server side language.
