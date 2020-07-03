# require 'httparty'
require "json"
require_relative "./html_response"
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
        body: HtmlResponse.show_form
      }
    end
  end
end
