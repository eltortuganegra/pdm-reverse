class YoutubeTrends
  GOOGLE_API_YOUTUBE_TRENDS_URL = 'https://www.googleapis.com/youtube/v3/videos'
  MAX_RESULTS_PER_REQUEST = 50

  def initialize
  end

  def apiRequestVideoList params = nil
    uri = getUriTrendsVideo
    response = Net::HTTP.get(uri)
  end

  def getUriTrendsVideo params = nil
    queryString = buildQueryString params
    uri = URI(GOOGLE_API_YOUTUBE_TRENDS_URL + queryString)
  end

  def getDefaultParamsQueryString
    {
        :part => 'contentDetails',
        :chart => 'mostPopular',
        :regionCode => 'IN',
        :maxResults => MAX_RESULTS_PER_REQUEST,
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