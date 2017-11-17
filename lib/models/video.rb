class Video
  attr_accessor :video_id,
                :youtube_id,
                :title,
                :description,
                :category_id,   # https://developers.google.com/youtube/v3/docs/videoCategories/list
                :keywords,      # 'Video keywords, comma-separated',
                :tags,      # 'Video keywords, comma-separated',
                :privacy_status # public | private | unlisted

  #https://developers.google.com/youtube/v3/docs/videos/list
  YOUTUBE_INFO_URI= 'http://youtube.com/get_video_info?video_id='
  YOUTUBE_UPLOAD_SCOPE = 'https://www.googleapis.com/auth/youtube.upload'
  YOUTUBE_API_SERVICE_NAME = 'youtube'
  YOUTUBE_API_VERSION = 'v3'
  DEFAULT_PRIVACY_STATUS = 'private'

  def initialize(youtube_trend = nil)
    if youtube_trend.nil?

      return nil
    end

    loadAttributes(youtube_trend)
  end

  def loadAttributes(youtube_trend)
    @youtube_id = youtube_trend.youtube_id
    loadTitle(youtube_trend)
    loadDescription(youtube_trend)
    @tags = youtube_trend.tags.nil? ? 'Funny Reverse' : youtube_trend.tags + ', [Funny Reverse]'
    @category_id = youtube_trend.category_id
  end

  def loadTitle(youtube_trend)
    @title = youtube_trend.title.nil? ? youtube_trend.youtube_id + ' [Funny Reverse]' : youtube_trend.title + ' | [Funny Reverse]'
  end

  def loadDescription(youtube_trend)
    # @description = youtube_trend.description.nil? ? youtube_trend.youtube_id + ' [REVERSE]' : getBeginDefaultDescription + youtube_trend.description
    @description = getDefaultDescription(youtube_trend)
  end

  def getDefaultDescription(youtube_trend)
    "[Funny Reverse]\n" + @title + "\nFunny reverse video\nYou can see the original video: https://youtube.com/watch?v=" + @youtube_id
  end

  def getBeginDefaultDescription
    "[Funny reverse]\nOriginal video: https://youtube.com/watch?v=" + @youtube_id + "\n---------\nOriginal description:\n"
  end

  def get_video_data_for_download
    video_data = get_video_data @youtube_id
    if (video_data.key?('status') && video_data['status'] == ['fail'])
      Logger::debug 'Status: fail. Reason: ' + video_data['reason'].to_s
      raise VideoDataForDownloadFailException.new('Status: ' + video_data['reason'].to_s + '. Errorcode: ' + video_data['reason'].to_s + '. Reason: ' + video_data['reason'].to_s)
    end

    # setVideoAttributes(video_data)

    privacy_status = Video::DEFAULT_PRIVACY_STATUS
    streams = get_video_streams video_data
    get_higher_resolution_video(streams)
  end

  def setVideoAttributes(video_data)
    Logger::debug "Video DATAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
    Logger::debug video_data.inspect

    @title = video_data['title'][0] + ' [Funny Reverse]'
    description = video_data.key?('description') ? video_data['description'][0] : ''
    @description = "Original: https://www.youtube.com/watch?v=" + @youtube_id + "\n\n" + description
    @keywords = video_data['keywords'][0] + ', reverse'
    @category_id = ''

    Logger::debug ""
    Logger::debug "Fill the video attributes:"
    Logger::debug "title: " + @title
    Logger::debug "description: " + @description
    Logger::debug "keywords: " + @keywords
    Logger::debug "category_id: " + @category_id

  end

  def get_video_data(youtube_id)
    # video_data = CGI.parse open(get_info_video_uri(youtube_id)).read
    video_data = CGI.parse(open(get_info_video_uri(youtube_id),  :allow_redirections => :safe).read)
    Logger::debug 'Video data:'
    Logger::debug video_data.inspect

    video_data
  end

  def get_info_video_uri(youtube_id)
    Video::YOUTUBE_INFO_URI + youtube_id
  end

  def get_video_streams(video_data)
    Logger::debug 'Get video streams'
    streams = video_data['url_encoded_fmt_stream_map'].first.split(',')
    streams.map! do |s|
      x = CGI.parse s
      x.each do |k,v|
        if k == 'type'
          x[k] = v.first.split('; ')
        else
          x[k] = v.first
        end
      end
    end
    Logger::debug 'Streams'
    Logger::debug streams.inspect

    streams
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

  def check_if_resolution_is_higher(video_data_for_download, video_data_quality)

    return (video_data_for_download['quality'] === 'hd1080') ||
        (video_data_for_download['quality'] === 'hd720' && video_data_quality['quality'] == 'hd1080') ||
        (video_data_for_download['quality'] === 'large' && (video_data_quality['quality'] === 'hd1080' || video_data_quality['quality'] === 'hd720')) ||
        (video_data_for_download['quality'] === 'medium' && (video_data_quality['quality'] === 'hd1080' || video_data_quality['quality'] === 'hd720' || video_data_quality['quality'] === 'large')) ||
        (video_data_for_download['quality'] === 'small' && (video_data_quality['quality'] === 'hd1080' || video_data_quality['quality'] === 'hd720' || video_data_quality['quality'] === 'large' || video_data_quality['quality'] === 'medium'))
  end

  def get_url_higher_resolution_video
    get_video_data_for_download['url']
  end

  def uploadVideoToYoutube



    # options = getOptionsForUpload
    #
    # Logger::debug options.inspect
    #
    # if options[:file].nil? or not File.file?(options[:file])
    #   Trollop::die :file, 'does not exist'
    # end
    #
    # client, youtube = get_authenticated_service
    # Logger::debug client.inspect
    # Logger::debug youtube.inspect
  end

  def getOptionsForUpload
    options = Trollop::options do
      opt :file, 'Video file to upload', :type => String,
          :default => 'downloads/R2u822BzQw8-reversed.mov'
      opt :title, 'Video title', :type => String,
          :default => 'Test Title'
      opt :description, 'Video description',
          :default => 'Test Description', :type => String
      opt :category_id, 'Numeric video category. See https://developers.google.com/youtube/v3/docs/videoCategories/list',
          :default => 22, :type => :int
      opt :keywords, 'Video keywords, comma-separated',
          :default => '', :type => String
      opt :privacy_status, 'Video privacy status: public, private, or unlisted',
          :default => 'public', :type => String
    end
    options
  end

  def get_authenticated_service


    client = Google::APIClient.new(
        :application_name => $PROGRAM_NAME,
        :application_version => '1.0.0'
    )
    youtube = client.discovered_api(self::YOUTUBE_API_SERVICE_NAME, self::YOUTUBE_API_VERSION)

    file_storage = Google::APIClient::FileStorage.new("#{$PROGRAM_NAME}-oauth2.json")
    if file_storage.authorization.nil?
      client_secrets = Google::APIClient::ClientSecrets.load
      flow = Google::APIClient::InstalledAppFlow.new(
          :client_id => client_secrets.client_id,
          :client_secret => client_secrets.client_secret,
          :scope => [self::YOUTUBE_UPLOAD_SCOPE]
      )
      client.authorization = flow.authorize(file_storage)
    else
      client.authorization = file_storage.authorization
    end

    return client, youtube
  end

  def load_from_search_result(youtube_search_result)

  end

end