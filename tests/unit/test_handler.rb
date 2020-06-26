require "json"
require "test/unit"
require "mocha/test_unit"

require_relative "../../user_form/show_form"

class ShowFormTest < Test::Unit::TestCase
  def mock_response
    Object.new.tap do |mock|
      mock.expects(:code).returns(200)
      mock.expects(:body).returns("1.1.1.1")
    end
  end

  def html_response
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

  def expected_result
    {
      statusCode: 200,
      headers: {'Content-Type': "text/html"},
      body: html_response
    }
  end

  def test_lambda_handler
    show_form_event = JSON.parse(File.read("tests/fixtures/show_form.json"))
    assert_equal(lambda_handler(event: show_form_event, context: ""), expected_result)
  end
end
