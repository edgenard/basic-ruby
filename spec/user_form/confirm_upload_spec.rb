require "spec_helper"
require_relative "../../user_form/confirm_upload"
require_relative "../fakes/lambda_context"

RSpec.describe UserForm::ConfirmUpload do
  let(:confirm_upload_event) {
    JSON.parse(File.read("spec/fixtures/confirm_upload.json"))
  }
  let(:region) { "test-region" }
  let(:key) { confirm_upload_event["queryStringParameters"]["key"] }
  let(:bucket) { "image-download" }
  let(:url_expiration_time) { 1 }

  let(:s3_presigned_url) do
    Aws::S3::Presigner.new(region: region)
      .presigned_url(:get_object, bucket: bucket, key: key, expires_in: 1 * 60)
  end

  before do
    ENV["AWS_REGION"] = region
    ENV["PROCESS_FORM_BUCKET"] = "test-bucket"
    ENV["URL_EXPIRATION"] = url_expiration_time.to_s
    ENV["IMAGE_DOWNLOAD_BUCKET"] = bucket
  end

  let(:success_html) do
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

  let(:success_response) {
    {
      statusCode: 200,
      headers: {'Content-Type': "text/html"},
      body: success_html
    }
  }

  subject(:handler) { UserForm::ConfirmUpload.handler(event: confirm_upload_event, context: FakeLambdaContext.new) }

  it "returns a message thanking the user for their submission" do
    expect(handler[:statusCode]).to eq(success_response[:statusCode])
  end

  it "returns a thank you message with the right submission id" do
    expect(handler[:body]).to eq(success_response[:body])
  end

  context "when there is an error processing the request" do
    let(:error_response) { success_response.merge(body: error_html) }
    let(:error_message) { "Some error processing the page" }
    let(:error_html) do
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
      allow(HtmlResponse).to receive(:successfully_processed_form).and_raise(error_message)
    end
    it "returns an error page" do
      expect(handler[:body]).to eq(error_response[:body])
    end
  end
end
