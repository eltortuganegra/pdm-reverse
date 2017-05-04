class Video
  YOUTUBE_INFO_URI= 'http://youtube.com/get_video_info?video_id='
  @video_id = nil

  def initialize(video_id = nil)
    @video_id = video_id
  end

  def getVideoDataForDownload
    video_data = get_video_data @video_id
    streams = get_video_streams video_data
    get_higher_resolution_video(streams)
  end

  def get_video_data(video_id)
    video_data = CGI.parse open(get_info_video_uri(video_id)).read
    Logger::debug 'Video data:'
    Logger::debug video_data.inspect

    video_data
  end

  def get_info_video_uri(video_id)
    Application::YOUTUBE_INFO_URI + video_id
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

end