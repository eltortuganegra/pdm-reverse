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
require_relative './models/search'
require_relative './models/youtube_trend'
require_relative './models/youtube_trend_status'
require_relative './models/youtube_video'
require_relative '../lib/youtube_search'
require_relative '../lib/models/youtube_video_status'
require_relative '../lib/exceptions/credentials_code_not_found_exception'
require_relative '../lib/exceptions/video_has_not_been_reversed_exception'
require_relative '../lib/exceptions/youtube_trend_with_pending_of_process_status_not_found_exception'
require_relative '../lib/exceptions/video_data_for_download_fail_exception'
require_relative '../lib/exceptions/youtube_upload_limit_exceeded_exception'
require_relative '../lib/exceptions/youtube_upload_invalid_or_empty_video_title_exception'
require_relative '../lib/youtube_api/youtube_api'
require_relative '../lib/youtube_api/youtube_api_get_video_info'
require_relative '../lib/youtube_api/youtube_api_search'
require_relative '../lib/youtube_api/youtube_api_video'
require_relative 'file_manager'
require_relative 'youtube_manager'
require_relative 'converter_manager'
require_relative 'downloads_manager'
require_relative 'youtube_trends'
require_relative 'google_authorization_manager'
require_relative 'youtube_search'
require_relative 'youtube_search_result'
require_relative 'youtube_video_tools'


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
        youtube_video = get_youtube_video_for_upload
        @downloads_manager.download(youtube_video)
        processTheDownloadedVideo(youtube_video)
        uploadProcessedVideoToYoutube(youtube_video)
        updateStatusToUploadedToYoutube(youtube_video)
        setUploadedDateToYoutubeVideo(youtube_video)
      rescue VideoHasNotBeenReversed => e
        youtube_video.youtube_video_status_id = YoutubeVideoStatus::ERROR_VIDEO_HAS_NOT_PROCESS
        if ! youtube_video.save
          Logger::debug 'youtube_video is not save'
        end
      rescue YoutubeTrendWithPendingOfProcessStatusNotFoundException => e
        Logger::debug 'Exception:'
        Logger::debug e.message
        break;
      rescue YoutubeUploadLimitExceededException
        Logger::debug 'Youtube upload limit. Waiting for ' + Application::DELAY_FOR_UPLOAD_LIMIT_EXCEEDED_EXCEPTION.to_s
        sleep Application::DELAY_FOR_UPLOAD_LIMIT_EXCEEDED_EXCEPTION
      ensure
        Logger::debug 'ENSURE'
        deleteTemporalVideos(youtube_video)
      end
    end
  end

  def setUploadedDateToYoutubeVideo(youtube_video)
    Logger::debug 'Uploaded at: ' + Time.now.strftime("%Y-%d-%m %H:%M:%S")
    youtube_video.uploaded_at = Time.now.strftime("%Y-%d-%m %H:%M:%S")
    youtube_video.save!
    Logger::debug youtube_video.inspect
  end

  def get_youtube_video_for_upload
    youtube_video = YoutubeVideo::get_youtube_video_with_newest_publication_date
    youtube_video.youtube_video_status_id = YoutubeVideoStatus::IN_PROCESS
    youtube_video.save!

    youtube_video
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
    Logger::debug 'ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ'
    Logger::debug 'Uploading video'
    Logger::debug 'youtube_video'
    Logger::debug youtube_video.inspect
    file_path = FileManager::get_downloaded_video_path_reversed(youtube_video.youtube_video_id)
    Logger::debug 'Path: ' + file_path.inspect
    youtubeManager = YoutubeManager.new @google_authorization_manager
    insert_video_response = youtubeManager.upload_video youtube_video, file_path

    youtube_video.processed_youtube_video_id = insert_video_response.id
    youtube_video.uploaded_at = DateTime.now.strftime('%s')

    insert_video_response
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

    downloaded_video_file_path = @downloads_manager.get_downloaded_video_path(youtube_video.youtube_video_id)
    Logger::debug 'Deleting processed video: ' + downloaded_video_file_path
    File.delete(downloaded_video_file_path) if File.exists?(downloaded_video_file_path)
  end

  def search_videos
    youtube_search = YoutubeSearch.new

    while (search = Search::get_query_with_older_last_search)
      Logger::debug 'Query string: ' + search.text
      Logger::debug 'Last search at: ' + search.last_search_at.inspect
      Logger::debug 'Time now: ' + Time.now.inspect
      Logger::debug 'One day ago: ' + 1.day.ago.inspect
      Logger::debug 'One day old?: ' + (( ! search.last_search_at.nil?) && (search.last_search_at > 1.day.ago)).inspect

      if (( ! search.last_search_at.nil?) && (search.last_search_at > 1.day.ago))
        Logger::debug 'All searchs have been searched in the 24 previous hours.'

        break
      end

      search.last_search_at = Time.now
      search.save

      youtube_search_results = youtube_search.request search
      Logger::debug 'Total videos: ' + youtube_search_results.length.to_s
      Logger::debug youtube_search_results.inspect

      youtube_search_results.each { |youtube_search_result|
        Logger::debug ''
        Logger::debug 'youtube_search_result:'
        Logger::debug youtube_search_result.inspect
        youtube_video = YoutubeVideo.new(youtube_search_result.to_hash)

        parameters = {
            :id => youtube_video.youtube_video_id
        }
        youtube_api_video_response = YoutubeApiVideo::get parameters
        YoutubeVideoTools::add_tags_from_youtube_api_video_reponse(youtube_video, youtube_api_video_response)

        begin
          youtube_video.save!
          Logger::debug 'This youtube_video has been saved successfully.'
        rescue ActiveRecord::RecordNotUnique
          Logger::debug 'Warning: This youtube_video has been saved before'
        rescue Exception => e
          Logger::debug 'Error: Video not saved!'
          Logger::debug "An error of type #{e.class} happened, message is #{e.message}"
          Logger::debug e.message
          Logger::debug e.backtrace.inspect
        end
      }

    end
  end

end


