# require 'httparty'
require "json"
require_relative "./html_response"
require "aws-sdk-s3"
# Sample pure Lambda function

# Parameters
# ----------
# event: Hash, required
#     API Gateway Lambda Proxy Input Format
#     Event doc: https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html#api-gateway-simple-proxy-for-lambda-input-format

# context: object, required
#     Lambda Context runtime methods and attributes
#     Context doc: https://docs.aws.amazon.com/lambda/latest/dg/ruby-context.html

# Returns
# ------
# API Gateway Lambda Proxy Output Format: dict
#     'statusCode' and 'body' are required
#     # api-gateway-simple-proxy-for-lambda-output-format
#     Return doc: https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html

# begin
#   response = HTTParty.get('http://checkip.amazonaws.com/')
# rescue HTTParty::Error => error
#   puts error.inspect
#   raise error
# end
module UserForm
  class ShowForm
    def self.handler(event:, context:)
      {
        statusCode: 200,
        headers: {"Content-Type": "text/html"},
        body: HtmlResponse.upload_form(form_options(event: event, context: context))
      }
    end

    def self.form_options(event:, context:)
      bucket = Aws::S3::Resource.new(region: ENV["AWS_REGION"]).bucket(ENV["PROCESS_FORM_BUCKET"])
      request_context = event["requestContext"]
      redirect_url = "https://#{request_context["domainName"]}/#{request_context["stage"]}/confirm"
      bucket.presigned_post(
        key: context.aws_request_id,
        acl: "private",
        success_action_redirect: redirect_url,
        content_type: "image/jpeg",
        server_side_encryption: "aws:kms",
        signature_expiration: Time.now + 600,
        content_length_range: 0...5000000
      )
    end
  end
end
