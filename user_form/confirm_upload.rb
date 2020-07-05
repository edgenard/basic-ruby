require_relative "./html_response"
require "aws-sdk-s3"
module UserForm
  class ConfirmUpload
    def self.handler(event:, context:)
      response = HtmlResponse.successfully_processed_form(event["queryStringParameters"]["key"])
      {
        statusCode: 200,
        headers: {'Content-Type': "text/html"},
        body: response
      }
    end
  end
end
