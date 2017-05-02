require 'open-uri'
require 'cgi'
require 'net/http'
require_relative 'Logger'

class Application
  YOUTUBE_INFO_URI= 'http://youtube.com/get_video_info?video_id='

  def run
    video_id = "R2u822BzQw8"
    video_data = get_video_data video_id
    streams = get_video_streams video_data
    video_data_for_download = get_higher_resolution_video(streams)
    download_higher_resolution_video(video_data_for_download, video_id)

    if ! File.exist? 'downloads/' + video_id
      Logger::debug 'File does not exist'
      return false
    end
    Logger::debug 'File exist'

    if ! system( get_reverse_video_command video_id )
      Logger::debug 'video is not reverse'
      return false
    end
    Logger::debug 'video is reverse'
    return true
  end

  def download_higher_resolution_video(video_data_for_download, video_id)
    File.open('downloads/' + video_id, "wb") do |saved_file|
      # the following "open" is provided by open-uri
      open(video_data_for_download['url'], "rb") do |read_file|
        Logger::debug 'Saved file!'
        saved_file.write(read_file.read)
      end
    end
  end

  def get_higher_resolution_video(streams)
    video_data_for_download = nil
    for video_data_quality in streams
      Logger::debug "-------------" \
           "Quality: #{video_data_quality['quality']}" \
           "Type: #{video_data_quality['type'].first}" \
           "URL:  #{video_data_quality['url']} \n\n"

      if video_data_for_download.nil? || (checkIfResolutionIsHigher video_data_for_download, video_data_quality)
        Logger::debug 'Set this video'
        video_data_for_download = video_data_quality
      end
    end

    Logger::debug 'Video with the higher resolution'
    Logger::debug video_data_for_download.inspect
    Logger::debug ''
    video_data_for_download
  end

  def checkIfResolutionIsHigher(video_data_for_download, video_data_quality)

    return (video_data_for_download['quality'] === 'hd1080') ||
       (video_data_for_download['quality'] === 'hd720' && video_data_quality['quality'] == 'hd1080') ||
       (video_data_for_download['quality'] === 'large' && (video_data_quality['quality'] === 'hd1080' || video_data_quality['quality'] === 'hd720')) ||
       (video_data_for_download['quality'] === 'medium' && (video_data_quality['quality'] === 'hd1080' || video_data_quality['quality'] === 'hd720' || video_data_quality['quality'] === 'large')) ||
       (video_data_for_download['quality'] === 'small' && (video_data_quality['quality'] === 'hd1080' || video_data_quality['quality'] === 'hd720' || video_data_quality['quality'] === 'large' || video_data_quality['quality'] === 'medium'))
  end

  def get_info_video_uri(video_id)
     Application::YOUTUBE_INFO_URI + video_id
  end

  def get_video_data(video_id)
    video_data = CGI.parse open(get_info_video_uri(video_id)).read
    Logger::debug 'Video data:'
    Logger::debug video_data.inspect

    video_data
  end

  def get_video_streams(video_data)
    Logger::debug 'Get video streams'
    streams = video_data['url_encoded_fmt_stream_map'].first.split(',')
    streams.map! do |s|
      x = CGI.parse s
      x.each do |k,v|
        if k == 'type'
          x[k] = v.first.split('; ')
        else
          x[k] = v.first
        end
      end
    end
    Logger::debug 'Streams'
    Logger::debug streams.inspect

    streams
  end

  def get_reverse_video_command video_id
    'ffmpeg -i ./downloads/' + video_id + ' -vf "reverse,hflip" -af areverse ./downloads/' + video_id + '-reversed.mp4'
  end

end


