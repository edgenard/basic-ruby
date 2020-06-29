require "spec_helper"
require "json"
require_relative "../../user_form/show_form"

RSpec.describe "#lambda_handler" do
  let(:show_form_event) {
    JSON.parse(File.read("spec/fixtures/show_form.json"))
  }
  let(:html_response) do
    <<~HTML
      <html>
      <head>
      </head>
      <body>
      <h1>Hello Please Enter Name</h1>
      <form method="post">
      <label for="name">Name:</label>
      <input type="text" id="name" name="name">
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
  subject(:handler) { lambda_handler(event: show_form_event, context: "") }

  it "returns an html form" do
    expect(handler).to eq(expected_result)
  end
end
