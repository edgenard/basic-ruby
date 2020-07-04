require_relative "./html_response"
require "aws-sdk-s3"
module UserForm
  class ProcessForm
    def self.handler(event:, context:)
      # body = URI.decode_www_form(event["body"]).to_h.to_json
      client = Aws::S3::Client.new(region: ENV["AWS_REGION"])
      client.put_object(bucket: ENV["PROCESS_FORM_BUCKET"], key: context.aws_request_id, body: event["body"])
      response = HtmlResponse.successfully_processed_form(context.aws_request_id)
      {
        statusCode: 201,
        headers: {'Content-Type': "text/html"},
        body: response
      }
    end
  end
end
