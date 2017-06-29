class YoutubeUploadLimitExceededException < StandardError

  def initialize(message = nil)
    if message.nil?
      message = getDefaultMessage
    end
    @message = message
    super
  end

  def getDefaultMessage
    'Youtube uploadLimitExceeded: The user has exceeded the number of videos they may upload.'
  end
end