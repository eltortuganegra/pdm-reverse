class YoutubeSearch
  YOUTUBE_SEARCH_LIST_ENDPOINT = 'https://www.googleapis.com/youtube/v3/search'

  def initialize

  end

  def request search
    query_string = build_query_string search
    response = YoutubeApiSearch::submit query_string
    youtube_search_results = create_youtube_search_results_from_parsed_json(response)

    youtube_search_results
  end

  def create_youtube_search_results_from_parsed_json(response)
    youtube_search_results = []
    response['items'].each { |json_video_data|
      youtube_search_result = YoutubeSearchResult.new(json_video_data)
      youtube_search_results.push(youtube_search_result)
    }
    youtube_search_results
  end

  def request_to_youtube_api(uri)
    response = Net::HTTP.get(uri)
  end

  def build_uri(query_string)
    uri = URI(YOUTUBE_SEARCH_LIST_ENDPOINT + query_string)
  end

  def build_query_string(search)
    default_parameters = get_default_parameters
    query_string = '?';
    default_parameters.each do |key, value|
       query_string += '&' + key.to_s + '=' + value
    end
    query_string += '&q=' + search.text

    query_string
  end

  def get_default_parameters()
    default_parameters = {
        :key => 'AIzaSyD7AB8zljxcqkmLQlVtWmBUUEOwm6D98Es',
        :part => 'id,snippet',
        :maxResults => '50',
        :type => 'video',
        :videoDuration => 'short',
        :videoEmbeddable => 'true',
        :videoSyndicated => 'true',
        :videoLicense => 'creativeCommon',
        :videoDefinition => 'high'
    }
  end

end