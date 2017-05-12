class Video
  attr_accessor :video_id
  YOUTUBE_INFO_URI= 'http://youtube.com/get_video_info?video_id='
  YOUTUBE_UPLOAD_SCOPE = 'https://www.googleapis.com/auth/youtube.upload'
  YOUTUBE_API_SERVICE_NAME = 'youtube'
  YOUTUBE_API_VERSION = 'v3'
  @video_id = nil

  def initialize(video_id = nil)
    @video_id = video_id
  end

  def get_video_data_for_download
    video_data = get_video_data @video_id
    streams = get_video_streams video_data
    get_higher_resolution_video(streams)
  end

  def get_video_data(video_id)
    video_data = CGI.parse open(get_info_video_uri(video_id)).read
    Logger::debug 'Video data:'
    Logger::debug video_data.inspect

    video_data
  end

  def get_info_video_uri(video_id)
    Video::YOUTUBE_INFO_URI + video_id
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



end