class YoutubeManager
  YT = Google::Apis::YoutubeV3
  OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'

  attr_accessor :google_authorization_manager

  def initialize google_authorization_manager
    @google_authorization_manager = google_authorization_manager
  end

  def upload_video(video, file_path)
    Logger::debug video.inspect
    Google::Apis.logger.level = Logger::DEBUG
    youtube = YT::YouTubeService.new
    youtube.authorization = @google_authorization_manager.credentials
    Logger::debug @google_authorization_manager.credentials.inspect
    metadata  = {
        snippet: {
            title: video.video_id + ' [REVERSE]'
        },
        status: {
            privacy_status: 'unlisted'
        }
    }

    Logger::debug 'Uploading video: ' + file_path
    result = youtube.insert_video('snippet,status', metadata, upload_source: file_path, content_type: "video/mp4")
    puts result.inspect
    puts "Upload complete"
  end

end