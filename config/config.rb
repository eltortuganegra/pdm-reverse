class Config
  attr_accessor :root_path, :downloads_path, :lib_path, :clients_secrets_path, :credentials_code_path

  def initialize
    Logger::debug 'Initialize config'
    setRootPath
    setDownloadsPath
    setLibPath
    setClientsSecretsPath
    setCredentialsCodePath
  end

  def setLibPath
    @lib_path = root_path.to_s + '/lib'
  end

  def setDownloadsPath
    @downloads_path = root_path.to_s + '/downloads'
  end

  def setRootPath
    @root_path = File.absolute_path(File.dirname(__FILE__) + '/..')
  end

  def setClientsSecretsPath
    @clients_secrets_path = root_path.to_s + '/config/clients_secrets.json'
  end

  def setCredentialsCodePath
    @credentials_code_path = root_path.to_s + '/config/credentials_code.json'
  end
end