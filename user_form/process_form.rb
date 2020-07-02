require_relative "./html_response"
module UserForm
  class ProcessForm
    def self.handler(event:, context:)
      response = HtmlResponse.successfully_processed_form(context.aws_request_id)
      {
        statusCode: 201,
        headers: {'Content-Type': "text/html"},
        body: response
      }
    end
  end
end
