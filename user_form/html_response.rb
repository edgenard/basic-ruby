require "erb"

module HtmlResponse
  def self.upload_form(presigned_post)
    template = <<~HTML
      <html>
      <head>
      <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
      </head>
      <body>
      <h1>Upload a JPEG</h1>
      <form action="<%= presigned_post.url %>" method="post" enctype="multipart/form-data">
      <% presigned_post.fields.each do |k, v| %>
      <input type="hidden" name="<%= k %>" value="<%= v %>">
      <% end %>
      <label for="file">File:</label>
      <input type="file" id="file" name="file" accept="image/jpeg">
      <input type="submit" value="Submit">
      </form>
      </body>
      </html>
    HTML
    view = ERB.new(template, trim_mode: "<>")
    view.result_with_hash(presigned_post: presigned_post)
  end

  def self.successfully_processed_form(submission_id, download_url)
    <<~HTML
      <html>
      <head>
      </head>
      <body>
      <h1>Thank You for your submission</h1>
      <h2>Your submission id is #{submission_id}</h2>
      <p>You can download your submission by <a href="#{download_url}">clicking here</a></p>
      </body>
      </html>
    HTML
  end
end
