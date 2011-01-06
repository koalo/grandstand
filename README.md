# Grandstand

Grandstand is a Rails 3 Gem that allows you to build totally simple blogs and portfolios using a gallery and blog post editor.

## 5-Minute Install

To get Grandstand up-and-running in five minutes or less:

1. In your terminal: `rails new site && cd site`
2. And then: `echo "gem 'grandstand', '>= 0.3.0'" >> Gemfile && bundle install`
3. And then: `rails generate grandstand:install`
4. And then: `rake db:migrate` and enter an e-mail and password for the first admin user
5. And then start Rails: `rails s`
6. Navigate to [http://localhost:3000/grandstand](http://localhost:3000/grandstand) to get started.

## Configuration

Grandstand uses S3 to store image files. In order to configure it, you need to take a peek at config/s3.yml and add your access keys there. Grandstand automatically generates this file for you. It should look like this:

	access_key_id: YOURSECRETACCESSID
	secret_access_key: YOUR-secRE/TACCe\ssKEy

Grandstand also generates config/initializers/grandstand.rb. It has examples of all the configuration options you can set in Grandstand, of which there are precious few. Here's an overview of them:

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
  "/grandstand"), etc. The following keys will work wonders for you:

		* :domain => The domain the admin interface should require users to be at. Useful if you want to piggyback on Heroku's SSL without paying for a certificate.
		* :path => The path for the admin interface. The default is 'http://localhost:3000/grandstand' but you can change to 'admin' or whatever to force it to 'http://localhost:3000/admin'
		* :ssl => require SSL. Best to turn this on in production (which is the default in config/initializers/grandstand.rb)

## Admin Interface

Grandstand has a basic admin interface that allows you to manage blog posts, galleries, and users. That's... like... it. You can access it by starting your app and visiting [http://localhost:3000/grandstand](http://localhost:3000/grandstand), where you'll need to log in with the username/password you set up when you installed Grandstand. Inside of it, you'll be able to edit galleries, blog posts, and users.

### Galleries

Grandstand's gallery editor is pretty straightforward. First, add a gallery. Then go to that gallery and upload images.

**Note:** I *very* strongly recommend you keep the multiple image uploader turned off until you've got SSL set up, as it has the potential to open up a security hole.

### Blog Posts

Blog posts come in one basic flavor: simple. The WYSIWYG editor will nicely clean pasted text including Word content (except in Firefox, which has shit access to the clipboard even when pasting). It will also let you embed images and, someday, entire galleries. Blog posts ***do not*** come with comments, since you're smart enough to be using Disqus or one of its friends. Plus, I'm fundamentally opposed to the idea of comments on blogs in the first place. All they've ever done is caused trouble.

### Users

Duh. These are the people using Grandstand. There are no roles, no specific permissions, no drafting processes. Just users.

## Bugs, Tests, and Contributions

Please file bug complaints in [Github Issues](http://github.com/flipsasser/grandstand/issues). Please also fork and do things like add tests or make the WYSIWYG editor work for the Grandstand::PagesController. I also need more documentation and your mom.


Copyright (c) 2011 Flip Sasser, released under the MIT license
