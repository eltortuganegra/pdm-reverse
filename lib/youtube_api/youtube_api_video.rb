class YoutubeApiVideo < YoutubeApi
  YOUTUBE_ENDPOINT = 'https://www.googleapis.com/youtube/v3/videos'

  protected
  def self.get_default_parameters
    default_parameters = {
        :key => 'AIzaSyD7AB8zljxcqkmLQlVtWmBUUEOwm6D98Es',
        :part => 'id,snippet'
    }
  end

end