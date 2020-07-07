require "spec_helper"
require_relative "../../user_form/confirm_upload"

class FakeLambdaContext
  attr_accessor :function_name, :function_version, :invoked_function_arn,
    :memory_limit_in_mb, :aws_request_id, :log_group_name, :log_stream_name,
    :deadline_ms, :identity, :client_context

  def get_remaining_time_in_millis
    3000
  end
end

RSpec.describe UserForm::ConfirmUpload do
  let(:confirm_upload_event) {
    JSON.parse(File.read("spec/fixtures/confirm_upload.json"))
  }
  let(:region) { "test-region" }
  let(:key) { confirm_upload_event["queryStringParameters"]["key"] }
  let(:bucket) { "test-bucket" }
  let(:url_expiration_time) { 1 }

  let(:s3_presigned_url) do
    Aws::S3::Presigner.new(region: region)
      .presigned_url(:get_object, bucket: bucket, key: key, expires_in: 1 * 60)
  end

  before do
    ENV["AWS_REGION"] = region
    ENV["PROCESS_FORM_BUCKET"] = bucket
    ENV["URL_EXPIRATION"] = url_expiration_time.to_s
  end

  let(:process_form_response) do
    <<~HTML
      <html>
      <head>
      </head>
      <body>
      <h1>Thank You for your submission</h1>
      <h2>Your submission id is #{key}</h2>
      <p>You can download your submission by <a href="#{s3_presigned_url}">clicking here</a></p>
      </body>
      </html>
    HTML
  end

  let(:expected_result) {
    {
      statusCode: 200,
      headers: {'Content-Type': "text/html"},
      body: process_form_response
    }
  }

  subject(:handler) { UserForm::ConfirmUpload.handler(event: confirm_upload_event, context: FakeLambdaContext.new) }

  it "returns a message thanking the user for their submission" do
    expect(handler[:statusCode]).to eq(expected_result[:statusCode])
  end

  it "returns a thank you message with the right submission id" do
    expect(handler[:body]).to eq(expected_result[:body])
  end
end
