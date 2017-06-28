class VideoDataForDownloadFailException < StandardError

  def initialize(message = nil)
    if message.nil?
      message = getDefaultMessage
    end
    @message = message
    super
  end

  def getDefaultMessage
    'Status: fail. Reason: Este vídeo incluye contenido de XXX y no se puede reproducir en algunos sitios web o aplicaciones.'
  end
end