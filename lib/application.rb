require 'rubygems'
require 'open-uri'
require 'open_uri_redirections'
require 'cgi'
require 'net/http'
require 'json'

# gem 'google-api-client', '>0.7'
# require 'google/api_client'
# require 'google/api_client/client_secrets'
# require 'google/api_client/auth/file_storage'
# require 'google/api_client/auth/installed_app'

require 'google/apis/youtube_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'active_record'


require_relative 'logger'
require_relative '../config/config'
require_relative './models/model'
require_relative './models/video'
require_relative './models/youtube_trend'
require_relative './models/youtube_trend_status'
require_relative './models/youtube_video'
require_relative '../lib/models/youtube_video_status'
require_relative '../lib/exceptions/credentials_code_not_found_exception'
require_relative '../lib/exceptions/video_has_not_been_reversed_exception'
require_relative '../lib/exceptions/youtube_trend_with_pending_of_process_status_not_found_exception'
require_relative '../lib/exceptions/video_data_for_download_fail_exception'
require_relative '../lib/exceptions/youtube_upload_limit_exceeded_exception'
require_relative '../lib/exceptions/youtube_upload_invalid_or_empty_video_title_exception'
require_relative '../lib/youtube_api/youtube_api_get_video_info'
require_relative 'file_manager'
require_relative 'youtube_manager'
require_relative 'converter_manager'
require_relative 'downloads_manager'
require_relative 'youtube_trends'
require_relative 'google_authorization_manager'


class Application
  attr_accessor :config,
                :google_authorization_manager,
                :downloads_manager,
                :converter_manager

  DELAY_FOR_UPLOAD_LIMIT_EXCEEDED_EXCEPTION = 300

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
    while true
      begin
        youtube_video = YoutubeVideo::get_youtube_video_with_newest_publication_date
        youtube_video.youtube_video_status_id = YoutubeVideoStatus::IN_PROCESS
        youtube_video.save!
        @downloads_manager.download(youtube_video)
        processTheDownloadedVideo(youtube_video)
        uploadProcessedVideoToYoutube(youtube_video)
        updateStatusToUploadedToYoutube(youtube_video)
        deleteTemporalVideos(youtube_video)
      rescue YoutubeTrendWithPendingOfProcessStatusNotFoundException => e
        Logger::debug 'Exception:'
        Logger::debug e.message
        break;
      rescue YoutubeUploadLimitExceededException
        Logger::debug 'Youtube upload limit. Waiting for ' + Application::DELAY_FOR_UPLOAD_LIMIT_EXCEEDED_EXCEPTION.to_s
        sleep Application::DELAY_FOR_UPLOAD_LIMIT_EXCEEDED_EXCEPTION
      end
    end
  end

  def select_youtube_trend_video_for_process
    youtube_trend = YoutubeTrend.where(youtube_trends_status_id: YoutubeTrendStatus::PENDING_OF_PROCESS).order(duration_in_seconds: :asc).limit(1).first
    Logger::debug 'Youtube id INSPECT: ' + youtube_trend.inspect
    raise YoutubeTrendWithPendingOfProcessStatusNotFoundException if youtube_trend.nil?

    Logger::debug 'Youtube id: ' + youtube_trend.youtube_id
    youtube_trend.youtube_trends_status_id = YoutubeTrendStatus::IN_PROCESS
    youtube_trend.save

    youtube_trend
  end

  def process_youtube_trend youtube_trend
    begin
      Logger::debug ""
      Logger::debug ""
      Logger::debug "------------------"
      Logger::debug "Youtube trend: " + youtube_trend.youtube_id
      Logger::debug "------------------"
      Logger::debug ""
      Logger::debug ""
      video = createNewVideo(youtube_trend)
      downloadVideo(video)
      processTheDownloadedVideo(video)
      uploadProcessedVideoToYoutube(video)
      updateStatusToUploadedToYoutube(youtube_trend)

    rescue VideoDataForDownloadFailException => e
      Logger::debug 'Video has not been downloaded'
      Logger::debug 'Video data for download is failing:'
      Logger::debug e.message

      youtube_trend.youtube_trends_status_id = YoutubeTrendStatus::FAIL_TO_DOWNLOAD_BY_FAIL_STATUS
      if ! youtube_trend.save!
        Logger::debug youtube_trend.errors.full_messages
      else
        Logger::debug 'saved'
        Logger::debug youtube_trend.inspect
      end

    rescue OpenURI::HTTPError => e
      Logger::debug 'Video has not been downloaded'
      Logger::debug 'HTTP Error: ' + e.message
      Logger::debug 'FAIL_TO_DOWNLOAD_BY_403_HTTP_CODE_STATUS: ' + YoutubeTrendStatus::FAIL_TO_DOWNLOAD_BY_403_HTTP_CODE_STATUS.inspect
      youtube_trend.youtube_trends_status_id = YoutubeTrendStatus::FAIL_TO_DOWNLOAD_BY_403_HTTP_CODE_STATUS
      Logger::debug YoutubeTrendStatus::FAIL_TO_DOWNLOAD_BY_403_HTTP_CODE_STATUS.to_s
      Logger::debug youtube_trend.inspect
      if ! youtube_trend.save!
        Logger::debug youtube_trend.errors.full_messages
      else
        Logger::debug 'saved'
        Logger::debug youtube_trend.inspect
      end
    rescue VideoHasNotBeenReversed => e
      youtube_trend.youtube_trends_status_id = YoutubeTrendStatus::FAIL_TO_REVERSE
      if ! youtube_trend.save
        Logger::debug 'Youtube_trend is not save'
      end
    rescue Google::Apis::ClientError => e
      Logger::debug '[Exception]' + e.message

      if ! e.message.index('invalidTitle').nil?
        youtube_trend.youtube_trends_status_id = YoutubeTrendStatus::FAIL_UPLOAD_INVALID_TITLE
        if ! youtube_trend.save!
          Logger::debug youtube_trend.errors.full_messages
        else
          Logger::debug 'saved'
          Logger::debug youtube_trend.inspect
        end
      else
        raise YoutubeUploadLimitExceededException.new
      end
    rescue Google::Apis::ServerError => e
        Logger::debug '[Exception] ' + e.message
        youtube_trend.youtube_trends_status_id = YoutubeTrendStatus::PENDING_OF_PROCESS
        if ! youtube_trend.save
          Logger.debug 'Youtube trend has not been saved!'
        else
          Logger.debug 'Youtube trend is pending of process again'
        end
    ensure
      Logger::debug 'ENSURE'
      deleteTemporalVideos(video)
    end
  end

  def updateStatusToUploadedToYoutube(youtube_video)
    youtube_video.youtube_video_status_id= YoutubeVideoStatus::UPLOADED_TO_YOUTUBE
    if youtube_video.save
      puts 'Youtube trend status updated to: UPLOADED_TO_YOUTUBE'
    else
      puts 'Youtube trend status updated can not update to: UPLOADED_TO_YOUTUBE'
    end
  end

  def uploadProcessedVideoToYoutube(youtube_video)
    Logger::debug 'Uploading video'
    file_path = FileManager::get_downloaded_video_path_reversed(youtube_video.youtube_video_id)
    Logger::debug 'Path: ' + file_path.inspect
    youtubeManager = YoutubeManager.new @google_authorization_manager
    youtubeManager.upload_video youtube_video, file_path

    file_path
  end

  def processTheDownloadedVideo(youtube_video)
    @converter_manager.convert youtube_video
  end

  def downloadVideo(video)
    @downloads_manager.download(video)
  end

  def createNewVideo(youtube_trend)
    video = Video.new youtube_trend
  end

  def deleteTemporalVideos(youtube_video)
    reversed_video_file_path = FileManager::get_downloaded_video_path_reversed(youtube_video.youtube_video_id)
    Logger::debug 'Deleting reversed video: ' + reversed_video_file_path
    File.delete(reversed_video_file_path) if File.exists?(reversed_video_file_path)

    downloaded_video_path = @downloads_manager.get_downloaded_video_path(youtube_video.youtube_video_id)
    Logger::debug 'Deleting processed video: ' + downloaded_video_path
    File.delete(downloaded_video_path) if File.exists?(downloaded_video_path)
  end

end


