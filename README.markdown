Grandstand
==========

Grandstand is a Rails 3 Gem that allows you to build totally simple blogs and portfolios using a gallery and blog post editor. It's as simple as adding

  gem 'grandstand'

to your `Gemfile` and running `bundle install`. Try it now!

Configuration
---
Grandstand has three (count 'em) configuration options.

1. Image sizes
Use this to control how your images are resized when they are uploaded. It's a hash that accepts the size name as the key and the
geometry string as the value, e.g.
  Grandstand.image_sizes[:large] = '800x600#'

2. Page sections


Authentication
---
Grandstand supports a very simple authentication scheme: users. With passwords! And that's it. It gives you a few helper methods, based on
most auth systems' standards:

  require_user
  
Use as a before filter or call it directly in your controllers. Simple. Easy-peasy. Passes the user back to the admin login page.

  current_user

Use in your controllers and views. Provides access to the logged-in user... if they're logged in.

Admin Interface
---
Grandstand has a basic admin interface that allows you to manage blog posts, galleries, pages, and users. That's... like... it.

Galleries
---


Copyright (c) 2010 Flip Sasser, released under the MIT license
