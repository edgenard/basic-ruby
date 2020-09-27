require "aws-sdk-s3"
require "fileutils"
require "image_processing"

module ImageResizing
  class CreateThumbnail
    ORIGINAL_FILE_PATH = "/tmp/original_file.jpg"
    THUMBNAIL_FILE_PATH = "/tmp/thumbnail.jpg"

    def self.handler(event:, context:)
      client = ::Aws::S3::Client.new(region: ENV["AWS_REGION"])
      thumbnail_bucket = ENV["THUMBNAIL_BUCKET"]
      uploaded_bucket = event["Records"][0]["s3"]["bucket"]["name"]
      uploaded_key = event["Records"][0]["s3"]["object"]["key"]
      client.get_object(response_target: ORIGINAL_FILE_PATH, bucket: uploaded_bucket, key: uploaded_key)
      original_file = File.open(ORIGINAL_FILE_PATH)
      ImageProcessing::Vips.source(original_file).resize_to_fit(ENV["THUMBNAIL_WIDTH"].to_i, nil).call(destination: THUMBNAIL_FILE_PATH)
      thumbnail_file = File.open(THUMBNAIL_FILE_PATH)

      client.put_object(acl: "private", body: thumbnail_file, bucket: thumbnail_bucket, key: uploaded_key)
    ensure
      File.truncate(THUMBNAIL_FILE_PATH, 0)
      File.truncate(ORIGINAL_FILE_PATH, 0)
    end
  end
end
