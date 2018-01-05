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
require_relative './controllers/controller'
require_relative './controllers/upload_videos_controller'
require_relative './controllers/search_videos_controller'
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
require_relative '../lib/exceptions/youtube_video_is_not_containing_all_keywords_of_the_search_exception'
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
require_relative 'youtube_video_validator'


class Application

  def upload_videos
    upload_videos_controller = UploadVideosController.new
    upload_videos_controller.run
  end

  def search_videos
    search_videos = SearchVideosController.new
    search_videos.run
  end

end


