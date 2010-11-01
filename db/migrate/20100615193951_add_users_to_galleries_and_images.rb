class AddUsersToGalleriesAndImages < ActiveRecord::Migration
  def self.up
    add_column :galleries, :user_id, :integer
    add_column :images, :user_id, :integer
  end

  def self.down
    remove_column :galleries, :user_id
    remove_column :images, :user_id
  end
end
