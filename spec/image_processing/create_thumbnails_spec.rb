require "spec_helper"
require_relative "../../image_processing/create_thumbnails"
require_relative "../fakes/lambda_context"

RSpec.describe ImageProcessing::CreateThumbnail do
  let(:s3_client_stub) { Aws::S3::Client.new(stub_responses: true) }
  let(:s3_put_event) { JSON.parse(File.read("spec/fixtures/create_thumbnails.json")) }
  let(:uploaded_object_key) { s3_put_event["Records"][0]["s3"]["object"]["key"] }
  let(:fake_context) { FakeLambdaContext.new }

  before do
    ENV["THUMBNAIL_BUCKET"] = "test-bucket"
    allow(Aws::S3::Client).to receive(:new).and_return(s3_client_stub)
  end

  it "uploads the image to the thumbnails bucket" do
    expect(s3_client_stub).to receive(:put_object).with(acl: "private", body: "/tmp/thumbnail.jpg", bucket: "test-bucket", key: uploaded_object_key)

    ImageProcessing::CreateThumbnail.handler(event: s3_put_event, context: fake_context)
  end
end
