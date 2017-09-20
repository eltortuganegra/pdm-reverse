class YoutubeSearchResult
  attr_accessor :youtube_video_id,
                :published_at,
                :channel_id,
                :title,
                :description

  def initialize(parsed_json)
    @youtube_video_id = parsed_json['id']['videoId']
    @published_at = parsed_json['snippet']['publishedAt']
    @channel_id = parsed_json['snippet']['channelId']
    @title = parsed_json['snippet']['title']
    @description = parsed_json['snippet']['description']
  end

  def to_hash
    hash = {
        :youtube_video_id => @youtube_video_id,
        :published_at => @published_at,
        :channel_id => @channel_id,
        :title => @title,
        :description => @description
    }
  end
end