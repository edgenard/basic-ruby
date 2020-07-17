module ImageProcessing
  module CreateThumbnails
    def self.handler(event:, context:)
      p "A change to deploy"
      p event
      p context
    end
  end
end
