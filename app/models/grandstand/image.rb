class Grandstand::Image < ActiveRecord::Base
  set_table_name :grandstand_images
  belongs_to :gallery
  belongs_to :user
  default_scope order('position, id')

  has_attached_file :file,
    :convert_options => Hash[*(Grandstand.image_sizes.keys + [:grandstand_icon, :grandstand_medium]).map {|key| [key, '-gravity North']}.flatten],
    :default_url => "http://dummyimage.com/:dimensions/fff/888&text=No+Images!",
    :path => '/images/:gallery_id/:padded_id-:style.:extension',
    :styles => {
      :grandstand_icon => '16x16#',
      :grandstand_medium => '200x200#'
    }.merge(Grandstand.image_sizes),
    :storage => :s3,
    :s3_credentials => Grandstand.s3[:credentials],
    :bucket => Grandstand.s3[:bucket]

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
      Grandstand::Image.attachment_definitions[:file][:styles].reject {|style, dimensions| style.to_s =~ /^grandstand_/ }.inject({}) do |sizes, style_definition|
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

  def sizes
    Hash[*Grandstand.image_sizes.keys.map {|size| [size, {:src => file.url(size)}] }.flatten]
  end

  protected
  def file_attached
    errors.add(:file, 'You must upload a file!') if file_file_name.blank?
  end
end
