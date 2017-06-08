require 'open-uri'
require 'cgi'
require 'net/http'
require 'json'

require 'rubygems'
# gem 'google-api-client', '>0.7'
# require 'google/api_client'
# require 'google/api_client/client_secrets'
# require 'google/api_client/auth/file_storage'
# require 'google/api_client/auth/installed_app'

require 'google/apis/youtube_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'

require_relative 'logger'
require_relative 'video'
require_relative 'file_manager'
require_relative 'youtube_manager'
require_relative 'converter_manager'
require_relative 'downloads_manager'
require_relative 'youtube_trends'
require_relative '../config/config'
require_relative 'google_authorization_manager'
require_relative '../lib/exceptions/credentials_code_not_found_exception'

class Application
  attr_accessor :config,
                :google_authorization_manager,
                :downloads_manager,
                :converter_manager

  def initialize
    begin
      @config = Config.new
      checkIfFileClientsSecretsJsonExist(@config)
      @google_authorization_manager = GoogleAuthorizationManager.new(@config)
      @downloads_manager = DownloadsManager.new @config
      @converter_manager = ConverterManager.new @config

    rescue Exception => e
      Logger::error e.message
      Logger::error e.inspect
      abort
    end
  end

  def checkIfFileClientsSecretsJsonExist(config)
    raise 'clients_secrets.json file not found at ' + config.clients_secrets_path if ! File.exist? config.clients_secrets_path
  end

  def run
    #URI para coger los más populares
    #https://www.googleapis.com/youtube/v3/videos?part=contentDetails&chart=mostPopular&regionCode=IN&maxResults=25&key=AIzaSyDu_K050qbIQQnw3ZJ2MTLS1lYssdh_B6E
    youtube_id = "5PqIwh_LxCg"
    video = Video.new youtube_id

    if ! @downloads_manager.download(video)
      Logger::debug 'Video has not been downloaded'
      return false
    end
    Logger::debug 'Video has been downloaded'

    Logger::debug 'Convert video'
    return false if ! @converter_manager.convert video




    Logger::debug 'Uploading video'
    file_path = FileManager::get_downloaded_video_path_reversed(video.youtube_id)

    Logger::debug 'SSSSSSSSSSSSSSSSS: '
    Logger::debug 'Path: ' + file_path.inspect


    youtube = YoutubeManager.new @google_authorization_manager
    youtube.upload_video video, file_path

    return true
  end

end


