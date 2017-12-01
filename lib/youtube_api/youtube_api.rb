class YoutubeApi
  YOUTUBE_ENDPOINT = ''

  def self.get parameters = nil
    if parameters.nil?
      parameters = get_default_parameters
    else
      parameters = get_default_parameters.merge(parameters)
    end
    query_string = build_query_string(parameters)

    submit query_string
  end

  protected
  def self.submit query_string
    uri = build_uri(query_string)
    Logger::debug 'Request to: ' + uri
    response = request_to_uri(uri)
    response_json = parse_response_to_json(response)

    response_json
  end

  def self.build_uri(query_string)
    self::YOUTUBE_ENDPOINT + query_string
  end

  def self.request_to_uri(uri)
    open(uri, :allow_redirections => :safe).read
  end

  def self.parse_response_to_json(response)
    JSON.parse(response)
  end

  def self.build_query_string(parameters)
    query_string = '?'
    parameters.each do |key, value|
      query_string += '&' + key.to_s + '=' + value
    end

    query_string
  end

  def self.get_default_parameters
    default_parameters = {}
  end

end