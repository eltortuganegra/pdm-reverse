class YoutubeTrendWithPendingOfProcessStatusNotFoundException < StandardError

  def initialize(message = nil)
    if message.nil?
      message = getDefaultMessage
    end
    @message = message
    super
  end

  def getDefaultMessage
    'youtube trend with pending of process status not found'
  end
end