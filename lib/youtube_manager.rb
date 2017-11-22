require_relative 'youtube_trends'

class YoutubeManager
  YT = Google::Apis::YoutubeV3
  OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
  GOOGLE_API_YOUTUBE_TRENDS_URL = 'https://www.googleapis.com/youtube/v3/videos'
  YOUTUBE_VIDEO_TITLE_MAXIMUM_SIZE = 100;
  DEFAULT_SUFFIX_FOR_TITLE = ' | FUNNY REVERSE'

  attr_accessor :google_authorization_manager

  def initialize google_authorization_manager
    @google_authorization_manager = google_authorization_manager
  end

  def upload_video(youtube_video, file_path)
    Logger::debug 'youtube manager -> upload_video'
    Logger::debug youtube_video.inspect
    Google::Apis.logger.level = Logger::DEBUG
    youtube = YT::YouTubeService.new
    youtube.authorization = @google_authorization_manager.credentials
    Logger::debug @google_authorization_manager.credentials.inspect

    metadata  = {
        snippet: {
            title: buildTitle(youtube_video),
            description: buildDescription(youtube_video),
            tags: ((youtube_video.tags.nil?) ? youtube_video.tags: youtube_video.tags.split(',')),
        },
        status: {
            embeddable: nil,
            privacy_status: 'public', # 'Video privacy status: public, private, or unlisted',
            license: "creativeCommon"
        }
    }

    Logger::debug "METADATA"
    Logger::debug metadata.inspect
    Logger::debug ''
    Logger::debug 'Title: ' + youtube_video.title
    Logger::debug 'Uploading video: ' + file_path
    insert_video_response = youtube.insert_video('snippet,status', metadata, upload_source: file_path, content_type: "video/mp4")
    # result = youtube.insert_video('snippet,status', metadata, upload_source: file_path, content_type: "video/mp4")
    Logger::debug 'Result of insert video:'
    puts insert_video_response.inspect
    puts "Upload completed"

    insert_video_response
  end

  def buildTitle(youtube_video)
    if (youtube_video.title.length > getMaximumSizeWithoutPrefix)
      title = youtube_video.title.encode('utf-8', :invalid => :replace, :undef => :replace)
      title[0, getMaximumSizeWithoutPrefix] + self::DEFAULT_SUFFIX_FOR_TITLE
    else
      youtube_video.title.encode('utf-8', :invalid => :replace, :undef => :replace) + self::DEFAULT_SUFFIX_FOR_TITLE
    end
  end

  def getMaximumSizeWithoutPrefix
    (self::YOUTUBE_VIDEO_TITLE_MAXIMUM_SIZE - self::DEFAULT_SUFFIX_FOR_TITLE.length)
  end

  def buildDescription(youtube_video)
    footer_description = "\n\n"\
      "----------" + "\n"\
      "This video is a derivated work from a video with a Creative Commons license." + "\n"\
      "You can see the original video: https://www.youtube.com/watch?v=" + youtube_video.youtube_video_id
    description = youtube_video.description + footer_description
  end

  def getTrends
    youtubeTrends = YoutubeTrends.new
    youtubeTrends.apiRequestVideoList
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

    Logger::debug 'Video with the higher resolution'
    Logger::debug video_data_for_download.inspect
    Logger::debug ''
    video_data_for_download
  end

end