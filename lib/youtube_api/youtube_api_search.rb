class YoutubeApiSearch
  YOUTUBE_SEARCH_LIST_ENDPOINT = 'https://www.googleapis.com/youtube/v3/search'

  def self.submit query_string
    uri = buid_uri(query_string)
    response = open(uri,  :allow_redirections => :safe).read
    response_json = JSON.parse(response)

    response_json
  end

  def self.buid_uri(query_string)
    self::YOUTUBE_SEARCH_LIST_ENDPOINT + query_string
  end

  def self.get_info_video_uri(youtube_video_id)
    YoutubeApiGetVideoInfo::YOUTUBE_INFO_URI + youtube_video_id
  end

end