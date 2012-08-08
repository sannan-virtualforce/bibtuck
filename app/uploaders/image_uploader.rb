# encoding: utf-8

class ImageUploader < CarrierWave::Uploader::Base

  # Include RMagick or ImageScience support:
  include CarrierWave::MiniMagick
  # include CarrierWave::ImageScience

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog
  # storage :s3

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "system/uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  def default_url
    "/images/camera_shy_#{version_name}.png"
  end

  # Process files as they are uploaded:
  # process :convert => 'png'
  process :resize_to_limit => [800, 800]
  process :store_geometry

  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  version :mini do
    process :resize_to_fill => [50, 50]
  end

  version :thumb do
    process :resize_to_fit => [91, 91]
  end

  version :avatar do
    process :resize_to_fill => [112, 112]
  end

  version :featured do
    process :resize_to_fit => [174, 323]
  end

  version :preview do
    process :resize_to_fit => [236, 323]
  end

  version :big do
    process :resize_to_fit => [298, 408]
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(png jpg gif jpeg)
  end

  # Override the filename of the uploaded files:
  # def filename
  #   super + '.png'
  # end

protected

  def store_geometry
    return unless model.kind_of?(Photo)
    if @file
      img = MiniMagick::Image.open(@file.file)
      model.width = img[:width]
      model.height = img[:height]
    end
  end
end
