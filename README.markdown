# Grandstand

Grandstand is a Rails 3 Gem that allows you to build totally simple blogs and portfolios using a gallery and blog post editor.

## 5-Minute Install

To get Grandstand up-and-running in five minutes or less, follow these steps:

1. Add `gem 'grandstand'` to your Rails 3 app's `Gemfile` and then run `bundle install`
2. Run `rake grandstand:install` to generate the assets and migrations needed to run Grandstand
3. Run `rake db:migrate` to install Grandstand. You will be prompted to enter a username and password for the admin interface
4. Update config/s3.yml with your Amazon S3 account credentials, which should look something like this:

        access_key_id: YOURSECRETACCESSID
        secret_access_key: YOUR-secRE/TACCe\ssKEy

5. Edit config/initializers/grandstand.rb and set a valid S3 bucket for your files, by changing

        Grandstand.s3[:bucket] = "changeme"

    to something like

        Grandstand.s3[:bucket] = "yourmom"

6. Start your Rails 3 app and open up [http://localhost:3000/grandstand](http://localhost:3000/grandstand) to start managing your stuff

## Configuration

Grandstand has three (count 'em) configuration options.

1. **Image sizes:** Used to control how your images are resized when they are uploaded. It's a hash
  that accepts the size name as the key and the geometry string as the value, e.g.

      Grandstand.image_sizes[:large] = '800x600#'

2. **S3 storage settings:** A Paperclip-style hash of S3 storage settings. You need to supply, at a
  minimum, a :bucket and a :credentials setting in order to upload images. Credentials will automatically
  be read from config/s3.yml, but you can override them as well. Ahem:

      Grandstand.s3[:bucket] = "yourmom"
      Grandstand.s3[:credentials] = {:access_key_id => "foo", :secret_access_key => "bar"}

  You can also do something like this:

      Grandstand.s3 = {:credentials => {:access_key_id => "foo", :secret_access_key => "bar"}, :bucket => "yourmom"}

3. **Admin routing settings:** Allow you to control the admin interface in certain ways, e.g. requiring SSL, using a
  different domain (for Heroku users, this will let you use the free SSL option), using a different path (default is
  "/grandstand"), etc.

## Authentication

Grandstand supports a very simple authentication scheme: users. With passwords! And that's it. It gives you a few methods,
based on auth systems' standards:

**`require_user`:** Use as a before filter or call it directly in your controllers. Simple. Easy-peasy. Passes the user back
to the admin login page.

**`current_user`:** Use in your controllers and views. Provides access to the logged-in user... if they're logged in.

## Admin Interface

Grandstand has a basic admin interface that allows you to manage blog posts, galleries, and users. That's... like... it. You can
access it by starting your app and visiting [http://localhost:3000/grandstand](http://localhost:3000/grandstand), where you'll need
to log in with the username/password you set up when you installed Grandstand. Inside of it, you'll be able to edit galleries, blog
posts, and users.

### Galleries

Grandstand's gallery editor is pretty straightforward. First, add a gallery. Then go to that gallery and upload images.

**Note:** I *very* strongly recommend you keep the multiple image uploader turned off until you've got SSL set up, as it
has the potential to open up a security hole.

### Blog Posts

Blog posts come in one basic flavor: simple. The WYSIWYG editor will nicely clean pasted text including Word content (except in Firefox,
which has shit access to the clipboard even when pasting). It will also let you embed images and, someday, entire galleries. Blog posts
***do not*** come with comments, since you're smart enough to be using Disqus or one of its friends. Plus, I'm fundamentally opposed to
the idea of comments on blogs in the first place. All they've ever done is caused trouble.

### Users

Duh. These are the people using Grandstand. There are no roles, no specific permissions, no drafting processes. Just users.

## Bugs, Tests, and Contributions

Please file bug complaints in [Github Issues](http://github.com/flipsasser/grandstand/issues). Please also fork and do things like add
tests or make the WYSIWYG editor work for the Grandstand::PagesController. I also need more documentation and your mom./


Copyright (c) 2010 Flip Sasser, released under the MIT license
