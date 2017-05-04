class Logger

  def self.debug message
    puts '[debug]' + getDateTime + ' ' + message
  end

  def self.error message
    puts '[error]' + getDateTime + ' ' +  message
  end

  private_class_method def self.getDateTime
    '[' + Time.now.inspect + ']'
  end

end