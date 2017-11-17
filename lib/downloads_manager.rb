class DownloadsManager
  attr_accessor :config

  def initialize config
    @config = config
  end

  def download youtube_video
    file_to_save = get_downloaded_video_path youtube_video.youtube_video_id
    Logger::debug 'file_to_save:' + file_to_save

    begin
      File.open(file_to_save, "wb") do |saved_file|
        url_video = get_url_higher_resolution_video youtube_video

        Logger::debug 'Url video: ' + url_video
        open(url_video, "rb") do |read_file|
          Logger::debug 'Saved file!'
          saved_file.write(read_file.read)
        end
      end

      File.exist? FileManager::get_downloaded_video_path(youtube_video.youtube_video_id)
    rescue Net::OpenTimeout => e
      Logger::debug 'ERROR:'
      Logger::debug 'timeout'
      Logger::debug e.inspect
    end

  end

  def get_downloaded_video_path youtube_video_id
    @config.downloads_path + '/' + youtube_video_id
  end

  def get_url_higher_resolution_video(youtube_video)
    video_data_response = YoutubeApiGetVideoInfo::submit youtube_video.youtube_video_id
    if (video_data_response.key?('status') && video_data_response['status'] == ['fail'])
      Logger::debug 'Status: fail. Reason: ' + video_data_response['reason'].to_s
      raise VideoDataForDownloadFailException.new('Status: ' + video_data_response['reason'].to_s + '. Errorcode: ' + video_data_response['reason'].to_s + '. Reason: ' + video_data_response['reason'].to_s)
    end
    streams = get_video_streams video_data_response
    video_data_for_download = get_higher_resolution_video(streams)

    video_data_for_download['url']
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

      if video_data_for_download.nil? || (check_if_resolution_is_higher video_data_for_download, video_data_quality)
        Logger::debug 'Set this video'
        video_data_for_download = video_data_quality
      end
    end

    Logger::debug 'Video with the higher resolution:'
    Logger::debug video_data_for_download.inspect
    Logger::debug ''

    video_data_for_download
  end


  def check_if_resolution_is_higher(video_data_for_download, video_data_quality)

    return (video_data_for_download['quality'] === 'hd1080') ||
        (video_data_for_download['quality'] === 'hd720' && video_data_quality['quality'] == 'hd1080') ||
        (video_data_for_download['quality'] === 'large' && (video_data_quality['quality'] === 'hd1080' || video_data_quality['quality'] === 'hd720')) ||
        (video_data_for_download['quality'] === 'medium' && (video_data_quality['quality'] === 'hd1080' || video_data_quality['quality'] === 'hd720' || video_data_quality['quality'] === 'large')) ||
        (video_data_for_download['quality'] === 'small' && (video_data_quality['quality'] === 'hd1080' || video_data_quality['quality'] === 'hd720' || video_data_quality['quality'] === 'large' || video_data_quality['quality'] === 'medium'))
  end

end