class Config
  attr_accessor :root_path, :downloads_path, :lib_path

  def initialize
    setRootPath
    setDownloadsPath
    setLibPath

  end

  def setLibPath
    @lib_path = @root_path + '/lib'
  end

  def setDownloadsPath
    @downloads_path = @root_path + '/downloads'
  end

  def setRootPath
    @root_path = File.absolute_path(File.dirname(__FILE__) + '/..')
  end
end