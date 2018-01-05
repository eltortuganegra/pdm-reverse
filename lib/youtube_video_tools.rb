class YoutubeVideoTools
  DEFAULT_TAGS = 'reverse,funny'

  def self.add_tags_from_youtube_api_video_reponse(youtube_video, youtube_api_video_response)
    if (youtube_api_video_response.key('items') &&
        youtube_api_video_response['items'].kind_of?(Array) &&
        youtube_api_video_response['items'].count > 0 &&
        youtube_api_video_response['items'][0].key('snippet') &&
        youtube_api_video_response['items'][0]['snippet'].key('tags')
        youtube_api_video_response['items'][0]['snippet']['tags'].kind_of?(Array) &&
        youtube_api_video_response['items'][0]['snippet']['tags'].count > 0)
      youtube_video.tags = youtube_api_video_response['items'][0]['snippet']['tags'].join(",") + ', ' + self::DEFAULT_TAGS
    else
      youtube_video.tags = self::DEFAULT_TAGS
    end
  end
end