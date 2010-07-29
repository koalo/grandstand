class Image < ActiveRecord::Base
  belongs_to :gallery
  belongs_to :user
  default_scope order('position, id')

  has_attached_file :file,
    :default_url => "http://dummyimage.com/:dimensions",
    :path => '/images/:padded_id-:style.:extension',
    :styles => {
      :admin_icon => '16x16#',
      :admin_medium => '200x200#'
    }.merge(Grandstand::Application.image_sizes),
    :storage => :s3,
    :s3_credentials => Grandstand::Application.s3[:credentials],
    :bucket => Grandstand::Application.s3[:bucket]

  delegate :url, :to => :file

  validates_presence_of :gallery
  validate :file_attached

  class << self
    # Returns the image sizes available for embedding in the public-facing pages. Sorts by potential pixel dimensions,
    # so icon sizes (75x75) return as smaller than page-width sizes (500x500 or whatever). Also adds a fun description
    # for the WYSIWYG editor, so '1024x768#' becomes '1024 x 768 (cropped)' in the event that the user is unhappy with
    # whatever goddamn sizes they're intended to accept.
    def sizes
      return @sizes if defined? @sizes
      sorted_sizes = ActiveSupport::OrderedHash.new
      Image.attachment_definitions[:file][:styles].reject {|style, dimensions| style.to_s =~ /^admin_/ }.inject({}) do |sizes, style_definition|
        style, dimensions = style_definition
        width, height = dimensions.gsub(/[^0-9x]/, '').split('x').map(&:to_i)
        width ||= 0
        height ||= 0
        if width.zero?
          description = "#{height} pixel#{'s' unless height == 1} tall; width to scale"
        elsif height.zero?
          description = "#{width} pixel#{'s' unless width == 1} wide; height to scale"
        else
          description = "#{width} x #{height}"
        end
        additional = []
        clean_dimensions = dimensions.gsub(/[0-9x]/, '')
        if clean_dimensions =~ /\#$/
          additional.push('cropped')
        end
        description << " (#{additional.join(', ')})" unless additional.empty?
        sizes[style.to_sym] = {:description => description, :dimensions => dimensions, :size => (width.zero? ? height : width) * (height.zero? ? width : height)}
        sizes
      end.sort {|a, b| a[1][:size] <=> b[1][:size] }.each do |key, value|
        sorted_sizes[key] = value
      end
      sorted_sizes
    end
  end

  protected
  def file_attached
    errors.add(:file, 'You must upload a file!') if file_file_name.blank?
  end
end
