class CreateImages < ActiveRecord::Migration
  def self.up
    create_table :images do |t|
      t.belongs_to :gallery
      t.string :string
      t.text :caption
      t.string :file_file_name
      t.string :file_content_type
      t.string :file_file_size
      t.string :file_updated_at
      t.integer :position
      t.timestamps
    end
  end

  def self.down
    drop_table :images
  end
end
