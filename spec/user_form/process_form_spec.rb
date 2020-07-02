require "spec_helper"
require_relative "../../user_form/process_form"

class FakeLambdaContext
  attr_accessor :function_name, :function_version, :invoked_function_arn,
    :memory_limit_in_mb, :aws_request_id, :log_group_name, :log_stream_name,
    :deadline_ms, :identity, :client_context

  def get_remaining_time_in_millis
    3000
  end
end

RSpec.describe UserForm::ProcessForm do
  let(:process_form_event) {
    JSON.parse(File.read("spec/fixtures/process_form.json"))
  }
  let(:context) { FakeLambdaContext.new }
  before do
    context.aws_request_id = "some-unique-random-stuff"
  end

  let(:process_form_response) do
    <<~HTML
      <html>
      <head>
      </head>
      <body>
      <h1>Thank You for your submission</h1>
      <h2>Your submission id is #{context.aws_request_id}</h2>
      </body>
      </html>
    HTML
  end

  let(:expected_result) {
    {
      statusCode: 201,
      headers: {'Content-Type': "text/html"},
      body: process_form_response
    }
  }

  it "returns a message thanking the user for their submission" do
    expect(UserForm::ProcessForm.handler(event: process_form_event, context: context)).to eq(expected_result)
  end
end
