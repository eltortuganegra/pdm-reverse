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

class Application
  def run
    #URI para coger los más populares
    #https://www.googleapis.com/youtube/v3/videos?part=contentDetails&chart=mostPopular&regionCode=IN&maxResults=25&key=AIzaSyDu_K050qbIQQnw3ZJ2MTLS1lYssdh_B6E
    video_id = "clcH15C2rjE"
    video = Video.new video_id
    # file_manager = FileManager.new
    # if ! file_manager.download_higher_resolution_video(video)
    #   Logger::debug 'File does not exist'
    #   return false
    # end
    # Logger::debug 'File exist'
    #
    # if ! system(get_reverse_video_command video_id )
    #   Logger::debug 'video is not reverse'
    #   return false
    # end
    Logger::debug 'video is reverse'
    file = '/var/www/pdm-reverse/' + FileManager::get_downloaded_video_path_reversed(video.video_id)
    youtube = YoutubeManager.new
    youtube.upload_video video, file

    return true
  end

  def get_reverse_video_command video_id
    'ffmpeg -i ' + FileManager::get_downloaded_video_path(video_id) + ' -vf "reverse,hflip" -af areverse ' + FileManager::get_downloaded_video_path_reversed(video_id)
  end

end


