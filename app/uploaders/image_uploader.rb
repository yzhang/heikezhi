# encoding: utf-8

class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::RMagick

  storage :file

  def geometry
    @geometry ||= get_geometry
  end

  def get_geometry
    if @file
      img = ::Magick::Image::read(@file.file).first
      geometry = { width: img.columns, height: img.rows }
    end
  end

  def store_dir
    "uploads/images/#{model.id}"
  end

  version :large do
    process :resize_to_fit => [600, 600]
  end

  version :thumb do
    process :resize_to_fit => [130, 130]
  end
end
