# Runway

Runway is a Controller and Views framework that can interface with the Rack middleware and generate views for the client based on HTTP requests sent. Runway was inspired by Rails and built using the Ruby programming language.

## Demo

The repo includes a demo as a proof-of-concept of the framework. To view the demo:

* Clone the Runway repository - `git clone https://github.com/tigerwins/Runway.git`
* Navigate to the Runway directory
* run `bundle install`
* run `ruby demo.rb`
* Go to `localhost:3000` in your browser to view!

## Features

### Controllers and Views

The `ControllerBase` class can be inherited by any custom controller to handle different request methods and paths and either render views or redirect to another URL. When rendered, the views are automatically pulled from the controller's own directory within the `views` directory.

```Ruby
def render(template_name)
  template_file = template_name.to_s + ".html.erb"
  path = "views/#{self.class.to_s.underscore}/#{template_file}"
  template = ERB.new(File.read(path)).result(binding)
  render_content(template, 'text/html')
end
```

Additionally, the framework generates an authenticity token to protect against CSRF attacks. This is verified in the controller through the `protect_from_forgery` and `check_authenticity_token` methods. The authenticity token must be included in every form that sends a `POST`, `PUT`, or `DELETE` request in order for the request to be accepted.

### Router

Runway includes a router that will allow you to specify routes to the controllers, dynamically handling `GET`, `POST`, `PUT`, and `DELETE` routes by using Ruby's `define_method`.

```Ruby
[:get, :post, :put, :delete].each do |http_method|
  define_method(http_method) do |pattern, controller_class, action_name|
    add_route(pattern, http_method, controller_class, action_name)
  end
end
```

When receiving an HTTP request, the router will instantiate the specified controller class and pass it the request method and data if the request matches a route.

### Flash

Rails' `flash` and `flash.now` are included in Runway. They can be interpolated into a view to allow users to see what errors they have run into and persist for two and one renders, respectively.

### Middleware

Runway includes a set of middleware to further expand its functionality:

* `show_exceptions.rb` handles exceptions and renders a custom view that displays the exception message and the stack trace of an error.
* `static.rb` allows users to serve static assets through URL paths. The middleware currently handles plain text (.txt), image (.jpg), and compressed (.zip) files.

## Future Directions

### Inclusion of Models

The logical next step would be to include models to make a complete MVC framework that would allow users to interact with a database and abstract away SQL code by wrapping database records in object instances. We would then have a complete backend capable of supporting a full-stack project.
