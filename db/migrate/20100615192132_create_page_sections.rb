class CreatePageSections < ActiveRecord::Migration
  def self.up
    create_table :page_sections do |t|
      t.belongs_to :page
      t.string :filter, :limit => 32
      t.string :section, :limit => 32
      t.integer :position, :default => 0
      t.text :content
      t.timestamps
    end
  end

  def self.down
    drop_table :page_sections
  end
end
