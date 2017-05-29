class CredentialsCodeNotFoundException < StandardError

  def initialize(message = nil)
    if message.nil?
      message = getDefaultMessage
    end
    @message = message
    super
  end

  def getDefaultMessage
    '"credentials_code.json" file not found. Please check your configuration files.'
  end
end