require 'open-uri'
require 'cgi'
require 'net/http'
require_relative 'Logger'
require_relative 'Video'

class Application
  YOUTUBE_INFO_URI= 'http://youtube.com/get_video_info?video_id='
  DOWNLOAD_FOLDER = 'downloads'
  def run
    video_id = "R2u822BzQw8"
    video = Video.new video_id
    download_higher_resolution_video(video.getVideoDataForDownload, video_id)

    if ! File.exist? get_downloaded_video_path(video_id)
      Logger::debug 'File does not exist'
      return false
    end
    Logger::debug 'File exist'

    if ! system(get_reverse_video_command video_id )
      Logger::debug 'video is not reverse'
      return false
    end
    Logger::debug 'video is reverse'
    return true
  end

  def get_downloaded_video_path(video_id)
    Application::DOWNLOAD_FOLDER + '/' + video_id
  end

  def get_downloaded_video_path_reversed(video_id)
    Application::DOWNLOAD_FOLDER + '/' + video_id + '-reversed.mp4'
  end

  def download_higher_resolution_video(video_data_for_download, video_id)
    File.open(get_downloaded_video_path(video_id), "wb") do |saved_file|
      # the following "open" is provided by open-uri
      open(video_data_for_download['url'], "rb") do |read_file|
        Logger::debug 'Saved file!'
        saved_file.write(read_file.read)
      end
    end
  end

  def get_reverse_video_command video_id
    'ffmpeg -i ' + get_downloaded_video_path(video_id) + ' -vf "reverse,hflip" -af areverse ' + get_downloaded_video_path_reversed(video_id)
  end

end


