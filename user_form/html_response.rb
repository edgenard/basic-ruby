module HtmlResponse
  def self.show_form
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

  def self.successfully_processed_form(submission_id)
    <<~HTML
      <html>
      <head>
      </head>
      <body>
      <h1>Thank You for your submission</h1>
      <h2>Your submission id is #{submission_id}</h2>
      </body>
      </html>
    HTML
  end
end
