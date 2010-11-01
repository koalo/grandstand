class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.belongs_to :user
      t.string :name
      t.string :url
      t.text :body
      t.text :preview
      t.timestamps
    end
  end

  def self.down
    drop_table :posts
  end
end
