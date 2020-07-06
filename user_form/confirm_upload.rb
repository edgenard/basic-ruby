require_relative "./html_response"
require "aws-sdk-s3"
module UserForm
  class ConfirmUpload
    def self.handler(event:, context:)
      object_key = event["queryStringParameters"]["key"]
      download_url = Aws::S3::Presigner.new(region: ENV["AWS_REGION"]).presigned_url(
        :get_object,
        bucket: ENV["PROCESS_FORM_BUCKET"],
        key: object_key,
        expires_in: ENV["URL_EXPIRATION"].to_i * 60
      )
      response = HtmlResponse.successfully_processed_form(object_key, download_url)
      {
        statusCode: 200,
        headers: {'Content-Type': "text/html"},
        body: response
      }
    end
  end
end
