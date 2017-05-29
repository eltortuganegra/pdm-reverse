require 'open-uri'
require 'cgi'
require 'net/http'
require 'trollop'

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
require_relative '../config/config'
require_relative 'google_authorization_manager'
require_relative '../lib/exceptions/credentials_code_not_found_exception'

class Application
  attr_accessor :config, :google_authorization_manager

  def initialize
    begin
      @config = Config.new
      checkIfFileClientsSecretsJsonExist(@config)
      @google_authorization_manager = GoogleAuthorizationManager.new(@config)
    rescue Exception => e
      Logger::error e.message
      abort
    end
  end

  def checkIfFileClientsSecretsJsonExist(config)
    raise 'clients_secrets.json file not found at ' + config.clients_secrets_path if !File.exist? config.clients_secrets_path
  end

  def run
    #URI para coger los más populares
    #https://www.googleapis.com/youtube/v3/videos?part=contentDetails&chart=mostPopular&regionCode=IN&maxResults=25&key=AIzaSyDu_K050qbIQQnw3ZJ2MTLS1lYssdh_B6E
    video_id = "StDQ_P99rPo"
    video = Video.new video_id

    file_manager = FileManager.new
    if ! file_manager.download_higher_resolution_video(video)
      Logger::debug 'File does not exist'
      return false
    end
    Logger::debug 'File exist'

    if ! system(get_reverse_video_command video_id )
      Logger::debug 'video is not reverse'
      return false
    end
    Logger::debug 'video is reverse'

    Logger::debug 'Uploading video'
    file_path = FileManager::get_downloaded_video_path_reversed(video.video_id)

    Logger::debug 'SSSSSSSSSSSSSSSSS: '
    Logger::debug 'Path: ' + file_path.inspect


    youtube = YoutubeManager.new @google_authorization_manager
    youtube.upload_video video, file_path

    return true
  end

  def get_reverse_video_command video_id
    'ffmpeg -i ' + FileManager::get_downloaded_video_path(video_id) + ' -vf "reverse,hflip" -af areverse ' + FileManager::get_downloaded_video_path_reversed(video_id)
  end

end


