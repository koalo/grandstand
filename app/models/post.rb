class Post < ActiveRecord::Base
  before_save :set_url
  belongs_to :user
  default_scope order('created_at DESC')

  validates_presence_of :name, :message => 'Your post needs a name'
  validates_uniqueness_of :name, :message => 'A post with that name already exists'

  class << self
    def extract_month(attribute)
      "strftime('%m', #{attribute})"
    end

    def extract_year(attribute)
      "strftime('%Y', #{attribute})"
    end
  end

  # def to_param
  #   url
  # end

  protected
  def set_url
    self.url ||= name.parameterize
  end
end
