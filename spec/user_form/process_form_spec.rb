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

  let(:fake_s3_client) { Aws::S3::Client.new(stub_responses: true) }
  let(:process_form_bucket) { "test-bucket" }
  let(:region) { "test-region" }
  let(:object_body) { {name: "Test submission"}.to_json }

  subject(:handler) { UserForm::ProcessForm.handler(event: process_form_event, context: context) }

  before do
    ENV["AWS_REGION"] = region
    ENV["PROCESS_FORM_BUCKET"] = process_form_bucket
    allow(Aws::S3::Client).to receive(:new).with(region: region).and_return(fake_s3_client)
  end

  it "returns a message thanking the user for their submission" do
    expect(handler).to eq(expected_result)
  end

  it "uploads the form submission to the S3 bucket" do
    expect(fake_s3_client).to receive(:put_object).with(bucket: process_form_bucket, key: context.aws_request_id, body: object_body)

    handler
  end
end
