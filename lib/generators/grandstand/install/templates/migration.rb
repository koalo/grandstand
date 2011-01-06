class InstallGrandstand < ActiveRecord::Migration
  def self.up
    create_table :grandstand_galleries do |t|
      t.integer :position
      t.string :name
      t.string :url
      t.text :description
      t.datetime :created_at
      t.datetime :updated_at
      t.integer :user_id
      t.boolean :published, :default => true
    end

    create_table :grandstand_images do |t|
      t.integer :gallery_id
      t.string :string
      t.text :caption
      t.string :file_file_name
      t.string :file_content_type
      t.string :file_file_size
      t.string :file_updated_at
      t.integer :position
      t.datetime :created_at
      t.datetime :updated_at
      t.integer :user_id
    end

    create_table :grandstand_page_sections do |t|
      t.integer :page_id
      t.string :filter, :limit => 32
      t.string :section, :limit => 32
      t.integer :position, :default => 0
      t.text :content
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :grandstand_pages do |t|
      t.integer :parent_id
      t.integer :user_id
      t.string :name
      t.string :slug
      t.string :url
      t.integer :position
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :grandstand_posts do |t|
      t.integer :user_id
      t.string :name
      t.string :url
      t.text :body
      t.text :preview
      t.datetime :created_at
      t.datetime :updated_at
      t.datetime :posted_at
    end

    create_table :grandstand_users do |t|
      t.string :email
      t.string :first_name
      t.string :last_name
      t.string :encrypted_password, :limit => 40
      t.string :salt, :limit => 40
      t.string :cookie, :limit => 40
      t.datetime :cookie_expires_at
      t.datetime :created_at
      t.datetime :updated_at
    end

    user_saved = false
    while !user_saved
      print 'Please enter an admin account e-mail (default: admin@localhost): '
      email = (email_tmp = $stdin.gets.strip).blank? ? 'admin@localhost' : email_tmp
      print "Please enter a password for #{email} (default: admin): "
      password = (password_tmp = $stdin.gets.strip).blank? ? 'admin' : password_tmp
      user = Grandstand::User.create(:email => email, :password => password)
      unless user_saved = !user.new_record?
        puts "  That user could not be saved: #{user.errors.inspect}"
      end
    end
    puts "Creating blog image library..."
    Grandstand::Gallery.create(:name => 'Blog Image Library', :published => false)
  end

  def self.down
    drop_table :grandstand_galleries
    drop_table :grandstand_images
    drop_table :grandstand_page_sections
    drop_table :grandstand_pages
    drop_table :grandstand_posts
    drop_table :grandstand_users
  end
end
