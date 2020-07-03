require "spec_helper"
require "json"
require_relative "../../user_form/show_form"

RSpec.describe UserForm::ShowForm do
  let(:show_form_event) {
    JSON.parse(File.read("spec/fixtures/show_form.json"))
  }
  let(:html_response) do
    <<~HTML
      <html>
      <head>
      </head>
      <body>
      <h1>Upload a JPEG</h1>
      <form method="post" enctype="multipart/form-data">
      <label for="file">File:</label>
      <input type="file" id="file" name="file" accept="image/jpeg, image/jpg">
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
  subject(:handler) { UserForm::ShowForm.handler(event: show_form_event, context: "") }

  it "returns an html form" do
    expect(handler).to eq(expected_result)
  end
end
