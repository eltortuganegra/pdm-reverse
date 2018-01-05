class YoutubeVideoIsNotContainingAllKeywordsOfTheSearchException < StandardError

def initialize(message = nil)
    if message.nil?
      message = getDefaultMessage
    end
    @message = message
    super
  end

  def getDefaultMessage
    'Youtube video: this video is not containing all keywords of the search.'
  end
end