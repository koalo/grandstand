class Grandstand::Page < ActiveRecord::Base
  attr_writer :new_parent_slug

  after_update :update_children
  before_validation :set_slug_and_url

  belongs_to :parent, :class_name => 'Page'
  belongs_to :user

  has_many :children, :class_name => 'Page', :foreign_key => :parent_id
  has_many :page_sections, :dependent => :destroy
  accepts_nested_attributes_for :page_sections, :reject_if => lambda {|page_section| page_section['content'].try(:strip).blank? }

  scope :roots, where(:parent_id => nil)

  validates_presence_of :name, :slug, :url

  class << self
    def per_page
      10
    end
  end

  def class_name
    @class_name ||= class_names.join(' ')
  end

  def class_names
    @class_names ||= page_sections.group_by(&:section).map{|section, page_sections| "has-#{section}"}
  end

  protected
  def set_slug_and_url
    self.slug ||= name.parameterize
    if new_record? || slug_changed? || parent_id_changed? || @new_parent_slug
      self.url = [parent.try(:url), slug].compact.join('/')
    end
  end

  def update_children
    if slug_changed? || parent_id_changed?
      children.each{|child| child.update_attributes(:new_parent_slug => true, :updated_at => Time.now) }
    end
  end
end
