class PageSection < ActiveRecord::Base
  belongs_to :page
  Grandstand::Application.page_sections.each do |section|
    scope section.to_sym, where(:section => section)
  end
end
