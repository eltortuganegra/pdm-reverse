class Logger

  def self.debug message
    puts getDateTime + '[debug]' + ' ' + message
  end

  def self.error message
    puts  getDateTime + '[error]' +' ' +  message
  end

  private_class_method def self.getDateTime
    '[' + Time.now.inspect + ']'
  end

end