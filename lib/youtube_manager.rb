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
    Logger::debug video.inspect
    Google::Apis.logger.level = Logger::DEBUG
    youtube = YT::YouTubeService.new
    youtube.authorization = @google_authorization_manager.credentials
    Logger::debug @google_authorization_manager.credentials.inspect
    metadata  = {
        snippet: {
            title: video.youtube_id + ' [REVERSE]'
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

  def getTrends
    # initialVideoList = apiRequestVideoList
    youtubeTrends = YoutubeTrends.new
    youtubeTrends.apiRequestVideoList
  end

  def apiRequestVideoList params = nil
    uri = getUriTrendsVideo
    Net::HTTP.get(uri)
  end

  def getUriTrendsVideo params = nil
    queryString = buildQueryString params
    puts queryString
    uri = URI(GOOGLE_API_YOUTUBE_TRENDS_URL + queryString)
  end

  def getDefaultParamsQueryString
    {
        :part => 'contentDetails',
        :chart => 'mostPopular',
        :regionCode => 'IN',
        :maxResults => 50,
        :key => 'AIzaSyDu_K050qbIQQnw3ZJ2MTLS1lYssdh_B6E'
    }
  end

  def buildQueryString params
    defaulfParams = getDefaultParamsQueryString
    puts defaulfParams.inspect
    defaulfParams.merge(params) if ! params.nil?
    query = ''
    defaulfParams.each {|key, value|
      query += '&' + key.to_s + '=' + value.to_s
    }

    '?' + query[1, query.length]
  end

end