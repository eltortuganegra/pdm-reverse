class VideoHasNotBeenReversed < StandardError

  def initialize(message = nil)
    if message.nil?
      message = getDefaultMessage
    end
    @message = message
    super
  end

  def getDefaultMessage
    'Video has not been reversed'
  end
end