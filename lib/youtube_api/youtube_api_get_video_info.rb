class YoutubeApiGetVideoInfo
  YOUTUBE_INFO_URI= 'http://youtube.com/get_video_info?video_id='

  def self.submit youtube_video_id
    video_data_response = CGI.parse(open(get_info_video_uri(youtube_video_id),  :allow_redirections => :safe).read)
    Logger::debug 'Video data response:'
    Logger::debug video_data_response.inspect
    Logger::debug 'Keys:'
    Logger::debug video_data_response.keys.inspect
    Logger::debug 'keywords:'
    Logger::debug video_data_response['keywords'].inspect

    video_data_response
  end

  def self.get_info_video_uri(youtube_video_id)
    YoutubeApiGetVideoInfo::YOUTUBE_INFO_URI + youtube_video_id
  end

end