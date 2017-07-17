require_relative 'youtube_trends'

class YoutubeManager
  YT = Google::Apis::YoutubeV3
  OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
  GOOGLE_API_YOUTUBE_TRENDS_URL = 'https://www.googleapis.com/youtube/v3/videos'

  attr_accessor :google_authorization_manager

  def initialize google_authorization_manager
    @google_authorization_manager = google_authorization_manager
  end

  def upload_video(video, file_path)
    Logger::debug 'youtube manager -> upload_video'
    Logger::debug video.inspect
    Google::Apis.logger.level = Logger::DEBUG
    youtube = YT::YouTubeService.new
    youtube.authorization = @google_authorization_manager.credentials
    Logger::debug @google_authorization_manager.credentials.inspect

    metadata  = {
        snippet: {
            title: video.title,
            description: video.description,
            tags: ((video.tags.nil?) ? video.tags: video.tags.split(',')),
            # keywords: video.keywords
        },
        status: {
            privacy_status: 'unlisted'
        }
    }

    Logger::debug "METADATA"
    Logger::debug metadata.inspect

    # Logger::debug ''
    # Logger::debug 'Title: ' + video.title
    # Logger::debug 'Uploading video: ' + file_path
    result = youtube.insert_video('snippet,status', metadata, upload_source: file_path, content_type: "video/mp4")
    puts result.inspect
    puts "Upload complete"

  end

  def getTrends
    youtubeTrends = YoutubeTrends.new
    youtubeTrends.apiRequestVideoList
  end

end