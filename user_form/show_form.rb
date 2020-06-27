# require 'httparty'
require "json"
module HtmlResponse
  def self.show_form
    <<~HTML
      <html>
      <head>
      </head>
      <body>
      <h1>Hello Please Enter Name</h1>
      <form method="post">
      <label for="name">Name:</label>
      <input type="text" id="name" name="name">
      <input type="submit" value="Submit">
      </form>
      </body>
      </html>
    HTML
  end
end

def lambda_handler(event:, context:)
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
  p "This one went through CodePipeline"
  {
    statusCode: 200,
    headers: {"Content-Type": "text/html"},
    body: HtmlResponse.show_form
  }
end
