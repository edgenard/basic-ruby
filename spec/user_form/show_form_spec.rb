require "spec_helper"
require "json"
require_relative "../../user_form/show_form"

class FakeLambdaContext
  attr_accessor :function_name, :function_version, :invoked_function_arn,
    :memory_limit_in_mb, :aws_request_id, :log_group_name, :log_stream_name,
    :deadline_ms, :identity, :client_context

  def get_remaining_time_in_millis
    3000
  end
end

RSpec.describe UserForm::ShowForm do
  let(:show_form_event) {
    JSON.parse(File.read("spec/fixtures/show_form.json"))
  }
  let(:region) { "test-region" }
  let(:bucket_name) { "upload-bucket-name" }
  let(:stub_resource) { Aws::S3::Resource.new(region: region, stub_responses: true) }
  let(:stub_bucket) { stub_resource.bucket(bucket_name) }
  let(:lambda_context) { FakeLambdaContext.new }
  let(:confirm_upload_endpoint) {
    "https://#{show_form_event["requestContext"]["domainName"]}" + "/" +
      show_form_event["requestContext"]["stage"] + "/" \
      "confirm"
  }
  let(:max_file_size) { 20 }
  let(:url_expiration_time) { 15 }
  let(:stub_presigned_post) do
    stub_bucket.presigned_post(
      key: lambda_context.aws_request_id,
      acl: "private",
      success_action_redirect: confirm_upload_endpoint,
      content_type: "image/jpeg",
      server_side_encryption: "aws:kms",
      signature_expiration: Time.now + url_expiration_time * 60,
      content_length_range: 0...(max_file_size * 1_000_000)
    )
  end

  before do
    ENV["AWS_REGION"] = region
    ENV["PROCESS_FORM_BUCKET"] = bucket_name
    ENV["MAX_FILE_SIZE"] = max_file_size.to_s
    ENV["URL_EXPIRATION"] = url_expiration_time.to_s
    lambda_context.aws_request_id = "some-unique-random-stuff"
    allow(Aws::S3::Resource).to receive(:new).with(region: region).and_return(stub_resource)
    allow(stub_resource).to receive(:bucket).with(bucket_name).and_return(stub_bucket)
  end

  let(:presigned_post_fields) do
    stub_presigned_post.fields.map { |k, v| "<input type=\"hidden\" name=\"#{k}\" value=\"#{v}\">" }
  end
  let(:html_response) do
    <<~HTML
      <html>
      <head>
      <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
      </head>
      <body>
      <h1>Upload a JPEG</h1>
      <form action="https://#{bucket_name}.s3.#{region}.amazonaws.com" method="post" enctype="multipart/form-data">
      #{presigned_post_fields.join("\n")}
      <label for="file">File:</label>
      <input type="file" id="file" name="file" accept="image/jpeg">
      <input type="submit" value="Submit">
      </form>
      </body>
      </html>
    HTML
  end
  let(:expected_result) do
    {
      statusCode: 200,
      headers: {'Content-Type': "text/html"},
      body: html_response
    }
  end
  subject(:handler) { UserForm::ShowForm.handler(event: show_form_event, context: lambda_context) }

  it "returns an html form" do
    expect(handler[:statusCode]).to eq(expected_result[:statusCode])
    expect(handler[:headers]).to eq(expected_result[:headers])
    expect(handler[:body]).to eq(expected_result[:body])
  end
end
