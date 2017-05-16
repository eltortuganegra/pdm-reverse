class YoutubeManager
  YT = Google::Apis::YoutubeV3
  OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'

  def upload_video(video, file_path)
    Logger::debug video.inspect
    Google::Apis.logger.level = Logger::DEBUG
    youtube = YT::YouTubeService.new
    youtube.authorization = user_credentials_for(YT::AUTH_YOUTUBE)
    metadata  = {
        snippet: {
            title: 'prueba'
        },
        status: {
            privacy_status: 'unlisted'
        }
    }
    # file = '/var/www/pdm-reverse/' + FileManager::get_downloaded_video_path_reversed(video.video_id)
    # result = youtube.insert_video('snippet,status', metadata, upload_source: file)
    result = youtube.insert_video('snippet,status', metadata, upload_source: file_path)
    puts result.inspect
    puts "Upload complete"
  end

  # Returns user credentials for the given scope. Requests authorization
  # if requrired.
  def user_credentials_for(scope)
    FileUtils.mkdir_p(File.dirname(token_store_path))

    if ENV['GOOGLE_CLIENT_ID']
      puts 'Get credential from environment'
      client_id = Google::Auth::ClientId.new(ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET'])
    else
      puts 'Get credential from file json: ' + client_secrets_path.to_s
      client_id = Google::Auth::ClientId.from_file(client_secrets_path)
      puts 'Client_id: ' + client_id.inspect
    end
    token_store = Google::Auth::Stores::FileTokenStore.new(:file => token_store_path)
    authorizer = Google::Auth::UserAuthorizer.new(client_id, scope, token_store)

    user_id = 'default'
    puts 'ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ'
    credentials = authorizer.get_credentials(user_id)
    puts credentials.inspect
    if ! credentials.nil?
      puts 'expired_at: ' + credentials.expires_at.to_s
      puts 'Now:        ' + Time.now.strftime("%Y-%m-%d %H:%M:%S")
      puts 'is less:        ' + (checkIfCredentialsIsExpired(credentials)).to_s
    end

    if credentials.nil? || checkIfCredentialsIsExpired(credentials)
      url = authorizer.get_authorization_url(base_url: OOB_URI)
      puts "Open the following URL in your browser and authorize the application."
      puts url
      # code = ask "Enter the authorization code:"
      code = '4/XBzueoqPFIdhA5dorwn0k7A_lyl5Wi7GM60Dr3GzFd4'
      code = '4/SFiD9Qljz07C3FtsuYLCWQ4j7zwZg_2hgcoRN78lSdw'
      puts 'CODE:' + code
      credentials = authorizer.get_and_store_credentials_from_code(
          user_id: user_id, code: code, base_url: OOB_URI)
      puts "\nCredentials: "
      puts credentials.inspect
      puts ''
      credentials
    end
    credentials
  end

  def checkIfCredentialsIsExpired(credentials)
    credentials.expires_at.to_s < Time.now.strftime("%Y-%m-%d %H:%M:%S")
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
  def client_secrets_path
    path = 'config/clients_secrets.example.json'
    return path if File.exist? path
    return ENV['GOOGLE_CLIENT_SECRETS'] if ENV.has_key?('GOOGLE_CLIENT_SECRETS')
    return well_known_path_for('clients_secrets.example.json')
  end
end