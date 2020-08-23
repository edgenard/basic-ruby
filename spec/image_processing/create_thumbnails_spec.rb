require "spec_helper"
require_relative "../../image_processing/create_thumbnails"
require_relative "../fakes/lambda_context"

RSpec::Matchers.define :same_file do |file|
  match { |actual_file| file.path == actual.path }
end

RSpec.describe ImageProcessing::CreateThumbnail do
  let(:s3_client_stub) { Aws::S3::Client.new(stub_responses: true) }
  let(:s3_put_event) { JSON.parse(File.read("spec/fixtures/create_thumbnails.json")) }
  let(:uploaded_object_key) { s3_put_event["Records"][0]["s3"]["object"]["key"] }
  let(:fake_context) { FakeLambdaContext.new }
  let(:thumbnail_file) { File.open(ImageProcessing::CreateThumbnail::THUMBNAIL_FILE_PATH) }
  let(:original_file) { File.open(ImageProcessing::CreateThumbnail::ORIGINAL_FILE_PATH) }
  before do
    ENV["THUMBNAIL_BUCKET"] = "test-bucket"
    allow(Aws::S3::Client).to receive(:new).and_return(s3_client_stub)
    s3_client_stub.stub_responses(:get_object, {body: 'Hello World'} )
  end

  it "uploads the image to the thumbnails bucket" do
    expect(s3_client_stub).to receive(:put_object).with(acl: "private", body: same_file(thumbnail_file), bucket: "test-bucket", key: uploaded_object_key)
    ImageProcessing::CreateThumbnail.handler(event: s3_put_event, context: fake_context)
  end

  it "deletes the temporary files" do
    ImageProcessing::CreateThumbnail.handler(event: s3_put_event, context: fake_context)

    expect(thumbnail_file.size).to eq(0)
    expect(original_file.size).to eq(0)
  end
end
