class Grandstand::Gallery < ActiveRecord::Base
  set_table_name :grandstand_galleries
  before_save :set_url
  belongs_to :user
  default_scope order('published, position, id ASC')
  has_many :images, :dependent => :destroy

  validates_presence_of :name, :message => 'Your gallery needs a name'
  validates_uniqueness_of :name, :message => 'A gallery with that name already exists'

  def cover_image
    images.first || Grandstand::Image.new
  end

  # def to_param
  #   url
  # end

  protected
  def set_url
    self.url ||= name.parameterize
  end
end
