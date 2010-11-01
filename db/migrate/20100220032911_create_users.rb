class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :email
      t.string :first_name
      t.string :last_name
      t.string :encrypted_password, :limit => 40
      t.string :salt, :limit => 40
      t.string :cookie, :limit => 40
      t.datetime :cookie_expires_at
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
