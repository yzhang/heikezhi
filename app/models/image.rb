class Image < ActiveRecord::Base
  mount_uploader :image_file, ImageUploader

  before_save  :save_image_dimensions

  default_scope order('created_at DESC')

  class FilelessIO < StringIO
    attr_accessor :original_filename
    attr_accessor :content_type
  end

  def as_json(options={})
    {
      id: id,
      src:   image_file.large.url,
      thumb: image_file.thumb.url,
      width: image_width
    }
  end

  private
  def save_image_dimensions
    if image_file_changed?
      self.image_width  = image_file.geometry[:width]
      self.image_height = image_file.geometry[:height]
    end
  end
end