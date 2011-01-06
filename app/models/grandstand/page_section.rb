class Grandstand::PageSection < ActiveRecord::Base
  set_table_name :grandstand_page_sections

  belongs_to :page
  Grandstand.page_sections.each do |section|
    scope section.to_sym, where(:section => section)
  end
end
