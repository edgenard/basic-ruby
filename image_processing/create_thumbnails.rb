require "aws-sdk-s3"
module ImageProcessing
  class CreateThumbnail
    def self.handler(event:, context:)
      client = ::Aws::S3::Client.new(region: ENV["AWS_REGION"])
      uploaded_bucket = event["Records"][0]["s3"]["bucket"]["name"]
      uploaded_key = event["Records"][0]["s3"]["object"]["key"]
      client.get_object(response_target: "/tmp/original_file.jpg", bucket: uploaded_bucket, key: uploaded_key)
      original_file = File.open("/tmp/original_file.jpg")
    rescue => e
      p e
      p e.message
    end
  end
end
