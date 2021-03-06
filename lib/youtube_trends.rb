class YoutubeTrends
  GOOGLE_API_YOUTUBE_TRENDS_URL = 'https://www.googleapis.com/youtube/v3/videos'
  MAX_RESULTS_PER_REQUEST = 50


  def initialize
  end

  def apiRequestVideoList params = nil
    item_list = []
    next_page_token = nil;
    counter = 6
    params = {}
    params['region_code'] = 'ES'
    # params['region_code'] = 'IN'
    # params['region_code'] = 'JP'
    # params['region_code'] = 'CH'
    # params['region_code'] = 'RU'
    # params['region_code'] = 'GB'
    # params['region_code'] = 'FR'
    # params['region_code'] = 'IT'
    # params['region_code'] = 'PT'
    # params['region_code'] = 'BR'
    # params['region_code'] = 'AR'
    # params['region_code'] = 'CO'
    # params['region_code'] = 'VE'
    # params['region_code'] = 'MX'
    # params['region_code'] = 'CA'

    while counter > 0 do
      uri = getUriTrendsVideo({
          :pageToken => next_page_token,
          :regionCode => params['region_code']
      })
      puts 'URI: ' + uri.to_s
      response = Net::HTTP.get(uri)
      parsed_response = JSON.parse(response)
      puts 'parsed_response:'
      puts parsed_response.inspect
      puts 'it\'s done'

      item_list.push(*parsed_response['items'])
      puts 'item_list values:'
      puts item_list.inspect
      puts 'Check next page'
      puts (parsed_response.key?('nextPageToken')).inspect
      break if ! parsed_response.key?('nextPageToken')
      next_page_token = parsed_response['nextPageToken']
      puts 'Token:' + parsed_response['nextPageToken']
      counter -= 1
    end

    item_list
  end

  def getUriTrendsVideo params = nil
    queryString = buildQueryString params

    uri = URI(GOOGLE_API_YOUTUBE_TRENDS_URL + queryString)
  end

  def getDefaultParamsQueryString
    {
        :part => 'contentDetails, snippet',
        :chart => 'mostPopular',
        # :regionCode => 'ES',
        :maxResults => MAX_RESULTS_PER_REQUEST,
        :key => 'AIzaSyD7AB8zljxcqkmLQlVtWmBUUEOwm6D98Es'
    }
  end

  def buildQueryString params
    defaulfParams = getDefaultParamsQueryString
    parameters_for_query = defaulfParams.merge(params)

    query_string = ''
    parameters_for_query.each {|key, value|
      if ! value.nil?
        query_string += '&' + key.to_s + '=' + value.to_s
      end
    }
    puts 'query_string: ' + query_string

    '?' + query_string[1, query_string.length]
  end
end