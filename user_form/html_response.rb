module HtmlResponse
  def self.upload_form(presigned_post)
    <<~HTML
      <html>
      <head>
      <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
      </head>
      <body>
      <h1>Upload a JPEG</h1>
      <form action="#{presigned_post.url}" method="post" enctype="multipart/form-data">
      <input type="hidden" name="key" value="#{presigned_post.fields["key"]}">
      <input type="hidden" name="acl" value="#{presigned_post.fields["acl"]}">
      <input type="hidden" name="success_action_redirect" value="#{presigned_post.fields["success_action_redirect"]}">
      <input type="hidden" name="Content-Type" value="#{presigned_post.fields["Content-Type"]}">
      <input type="hidden" name="x-amz-server-side-encryption" value="#{presigned_post.fields["x-amz-server-side-encryption"]}">
      <input type="hidden" name="x-amz-credential" value="#{presigned_post.fields["x-amz-credential"]}">
      <input type="hidden" name="x-amz-algorithm" value="#{presigned_post.fields["x-amz-algorithm"]}">
      <input type="hidden" name="x-amz-date" value="#{presigned_post.fields["x-amz-date"]}">
      <input type="hidden" name="Policy" value="#{presigned_post.fields["policy"]}">
      <input type="hidden" name="x-amz-signature" value="#{presigned_post.fields["x-amz-signature"]}">
      <input type="hidden" name="x-amz-security-token" value="#{presigned_post.fields["x-amz-security-token"]}">
      <label for="file">File:</label>
      <input type="file" id="file" name="file" accept="image/jpeg">
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
