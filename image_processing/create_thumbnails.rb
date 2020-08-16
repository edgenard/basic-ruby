require "aws-sdk-s3"
require "fileutils"

module ImageProcessing
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
      thumbnail_file = File.new(THUMBNAIL_FILE_PATH, "w+")
      FileUtils.cp(original_file, thumbnail_file)

      client.put_object(acl: "private", body: thumbnail_file, bucket: thumbnail_bucket, key: uploaded_key)
    rescue => e
      p e
      p e.message
    end
  end
end
