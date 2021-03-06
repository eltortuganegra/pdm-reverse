class YoutubeUploadInvalidOrEmptyVideoTitleException < StandardError

  def initialize(message = nil)
    if message.nil?
      message = getDefaultMessage
    end
    @message = message
    super
  end

  def getDefaultMessage
    'Youtube invalid or empty video title'
  end
end