class Logger

  def self.debug message
    puts '[debug]' + message
  end

  def self.error message
    puts '[error]' + message
  end
end