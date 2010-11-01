class CreatePages < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      t.belongs_to :parent
      t.belongs_to :user
      t.string :name
      t.string :slug
      t.string :url
      t.integer :position
      t.timestamps
    end
  end

  def self.down
    drop_table :pages
  end
end
