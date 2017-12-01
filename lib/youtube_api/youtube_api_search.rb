class YoutubeApiSearch < YoutubeApi
  YOUTUBE_ENDPOINT = 'https://www.googleapis.com/youtube/v3/search'

  protected
  def self.get_default_parameters
    default_parameters = {
        :key => 'AIzaSyD7AB8zljxcqkmLQlVtWmBUUEOwm6D98Es',
        :part => 'id,snippet',
        :maxResults => '50',
        :type => 'video',
        :videoDuration => 'short',
        :videoEmbeddable => 'true',
        :videoSyndicated => 'true',
        :videoLicense => 'creativeCommon',
        :videoDefinition => 'high'
    }
  end
end