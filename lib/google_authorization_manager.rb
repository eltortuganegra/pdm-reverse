class GoogleAuthorizationManager
  YT = Google::Apis::YoutubeV3
  OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
  attr_accessor :credentials

  def initialize(config)
    Logger::debug 'Creating token store path at: ' + token_store_path
    FileUtils.mkdir_p(File.dirname(token_store_path))

    if ENV['GOOGLE_CLIENT_ID']
      Logger::debug 'Get credential from environment'
      client_id = Google::Auth::ClientId.new(ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET'])
    else
      Logger::debug 'Get credential from file json: ' + client_secrets_path.to_s
      client_id = Google::Auth::ClientId.from_file(client_secrets_path)
      Logger::debug 'Client_id: ' + client_id.inspect
    end

    token_store = Google::Auth::Stores::FileTokenStore.new(:file => token_store_path)
    authorizer = Google::Auth::UserAuthorizer.new(client_id, YT::AUTH_YOUTUBE, token_store)
    user_id = 'default'
    puts token_store.inspect
    puts authorizer


    begin
      storeCredentialsFromCredentialsCodeFile(authorizer, user_id, config.credentials_code_path)
      @credentials = authorizer.get_credentials(user_id)

      Logger::debug 'Check credentials'
      Logger::debug @credentials.inspect
      if ! @credentials.nil?
        Logger::debug 'expired_at: ' + @credentials.expires_at.to_s
        Logger::debug 'Now:        ' + Time.now.strftime("%Y-%m-%d %H:%M:%S")
        Logger::debug 'is less:        ' + (checkIfCredentialsIsExpired(@credentials)).to_s
        File.write(config.runtime_path + '/credentials.json', {
            :expired_at => @credentials.expires_at,
            :scope => @credentials.scope,
            :access_token => @credentials.access_token,
            :refresh_token => @credentials.refresh_token
        }.to_json)
      end
    rescue CredentialsCodeNotFoundException => e
      raise e
    rescue Exception => e

      Logger::debug 'ZZZZZZ'
      Logger::debug e.inspect
      Logger::debug @credentials.inspect

      if @credentials.nil? || checkIfCredentialsIsExpired(@credentials)
        url = authorizer.get_authorization_url(base_url: OOB_URI)
        # puts "Open the following URL in your browser and authorize the application."
        # puts url
        showUrlForGetCredentialCode(url)
      end
    end
  end

  def storeCredentialsFromCredentialsCodeFile(authorizer, user_id, credentials_code_path)
    # code = ask "Enter the authorization code:"
    # code = '4/jV4_ZJrmWwpNOTAZ4r_xjxRDdx4da6PjIIR8HGgtfoI'
    # credentials_code = '/var/www/ruby/pdm-reverse/config/credentials_code.txt'
    raiseExceptionIfCredentialCodeJsonFileNotExist(credentials_code_path)
    
    code = File.read(credentials_code_path)
    Logger::debug 'CODE:' + code
    begin
    @credentials = authorizer.get_and_store_credentials_from_code(
        user_id: user_id, code: code, base_url: OOB_URI)
    Logger::debug "\nCredentials: "
    Logger::debug credentials.inspect
    Logger::debug ''
    rescue Exception => e
      Logger::debug 'Token is expired'
      Logger::debug @credentials.inspect
      Logger::debug e.inspect

    end
  end

  def raiseExceptionIfCredentialCodeJsonFileNotExist(credentials_code_path)
    raise CredentialsCodeNotFoundException.new if !File.exist? credentials_code_path
  end

  def showUrlForGetCredentialCode(url)
    message = "\nYou need credential code for upload a video. Open the following URL in your browser and authorize the application: \n\n" + url
    message += "\n\n"

    raise message
  end

  # Returns the path to the token store.
  def token_store_path
    return ENV['GOOGLE_CREDENTIAL_STORE'] if ENV.has_key?('GOOGLE_CREDENTIAL_STORE')
    return well_known_path_for('credentials.yaml')
  end

  # Builds a path to a file in $HOME/.config/google (or %APPDATA%/google,
  # on Windows)
  def well_known_path_for(file)
    if OS.windows?
      dir = ENV.fetch('HOME'){ ENV['APPDATA']}
      File.join(dir, 'google', file)
    else
      File.join(ENV['HOME'], '.config', 'google', file)
    end
  end

  # Returns the path to the client_secrets.json file.
  def   client_secrets_path
    path = 'config/clients_secrets.json'
    return path if File.exist? path
    return ENV['GOOGLE_CLIENT_SECRETS'] if ENV.has_key?('GOOGLE_CLIENT_SECRETS')
    return well_known_path_for('clients_secrets.json')
  end

  def checkIfCredentialsIsExpired(credentials)
    credentials.expires_at.to_s < Time.now.strftime("%Y-%m-%d %H:%M:%S")
  end

end