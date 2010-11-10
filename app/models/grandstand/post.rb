class Grandstand::Post < ActiveRecord::Base
  before_save :set_url
  before_validation :set_posted_at
  belongs_to :user
  default_scope order('posted_at DESC, created_at DESC, id DESC')

  scope :posted_on, lambda {|year, month| where("#{extract_year('posted_at')} = ? AND #{extract_month('posted_at')} = ?", year, month.to_s.rjust(2, '0')) }

  validates_presence_of :name, :message => 'Your post needs a name'
  validates_presence_of :posted_at
  validates_uniqueness_of :name, :message => 'A post with that name already exists'

  class << self
    def extract_month(attribute)
      case configurations[Rails.env]['adapter'].to_sym
      when :sqlite, :sqlite3
        "strftime('%m', #{attribute})"
      when :postgre, :postgres, :postgresql
        "EXTRACT(month FROM #{attribute})"
      when :mysql
        "MONTH(#{attribute})"
      end
    end

    def extract_year(attribute)
      case configurations[Rails.env]['adapter'].to_sym
      when :sqlite, :sqlite3
        "strftime('%Y', #{attribute})"
      when :postgre, :postgres, :postgresql
        "EXTRACT(year FROM #{attribute})"
      when :mysql
        "YEAR(#{attribute})"
      end
    end
  end

  def to_html
    @to_html ||= Mustache.render(Grandstand::Template.post, as_json)
  end

  # def to_param
  #   url
  # end

  protected
  def set_posted_at
    self.posted_at ||= Time.now
  end

  def set_url
    self.url ||= name.parameterize
  end
end
