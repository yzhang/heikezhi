class ImagesController < ApplicationController
  before_filter :authenticate_user!

  def create
    process_image_data
    image = current_user.images.create(image_file: params[:image][:image_file])

    respond_to do |wants|
      wants.json { render :json => image}
    end
  end

  private
  def process_image_data
    return unless params[:image]
    image_data = params[:image].delete(:image_data)
    return unless image_data.present?

    r = /^data:image\/(.*?);base64,(.*?)$/.match(image_data)
    ext     = r[1]
    data    = r[2]
    decoded = Base64.decode64(data)

    raw = Image::FilelessIO.new(decoded)
    raw.original_filename = "img.#{ext}"
    raw.content_type = "image/#{ext}"
    params[:image][:image_file] = raw
  end
end