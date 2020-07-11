require "spec_helper"
require "json"
require_relative "../../user_form/show_form"
require_relative "../fakes/lambda_context"

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
  let(:form_page) do
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
  let(:default_response) do
    {
      statusCode: 200,
      headers: {'Content-Type': "text/html"},
      body: form_page
    }
  end
  subject(:handler) { UserForm::ShowForm.handler(event: show_form_event, context: lambda_context) }

  it "returns an html form" do
    expect(handler[:statusCode]).to eq(default_response[:statusCode])
    expect(handler[:headers]).to eq(default_response[:headers])
    expect(handler[:body]).to eq(default_response[:body])
  end

  context "when an error occurs processing the request" do
    let(:error_response) do
      default_response.merge({body: error_page})
    end
    let(:error_message) { "Error Creating Form Somehow" }
    let(:error_page) do
      <<~HTML
        <html>
        <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        </head>
        <body>
        <h1>Error Processing Request</h1>
        <p>#{error_message}</p>
        </body>
        </html>
      HTML
    end

    before do
      allow(HtmlResponse).to receive(:upload_form).and_raise(error_message)
    end
    it "returns an error page" do
      expect(handler[:statusCode]).to eq(error_response[:statusCode])
      expect(handler[:headers]).to eq(error_response[:headers])
      expect(handler[:body]).to eq(error_response[:body])
    end
  end
end
