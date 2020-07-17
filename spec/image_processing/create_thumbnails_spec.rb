require "spec_helper"
require "json"
require_relative "../../image_processing/create_thumbnails"
require_relative "../fakes/lambda_context"

RSpec.describe ImageProcessing::CreateThumbnails do
  let(:create_thumbnails_event) { JSON.parse(File.read("spec/fixtures/create_thumbnails.json")) }
  let(:bucket) { "example-bucket" }
  let(:key) { "some-random-stuff" }
  let(:region) { "test-region" }

  subject(:create_thumbnails) { ImageProcessing::CreateThumbnails.handler(event: create_thumbnails_event, context: FakeLambdaContext.new) }

  let(:stubbed_s3_resource) { Aws::S3::Resource.new(region: region, stubbed_responses: true) }

  it "downloads the file to a tmp directory" do
  end
end
