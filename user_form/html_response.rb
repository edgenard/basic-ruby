module HtmlResponse
  def self.show_form
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
