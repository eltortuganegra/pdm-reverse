class YoutubeSearch
  YOUTUBE_SEARCH_LIST_ENDPOINT = 'https://www.googleapis.com/youtube/v3/search'

  def initialize

  end

  def request search

    queryString = build_query_string search
    uri = build_uri(queryString)
    Logger::debug 'Uri: ' + uri.inspect

    response = request_to_youtube_api(uri)
    parsed_response = JSON.parse(response)
    youtube_search_results = create_youtube_search_results_from_parsed_json(parsed_response)

    search.last_search_at = Time.now
    search.save

    youtube_search_results
  end

  def create_youtube_search_results_from_parsed_json(parsed_response)
    youtube_search_results = []
    parsed_response['items'].each { |json_video_data|
      youtube_search_result = YoutubeSearchResult.new(json_video_data)
      youtube_search_results.push(youtube_search_result)
    }
    youtube_search_results
  end

  def request_to_youtube_api(uri)
    response = Net::HTTP.get(uri)
  end

  def build_uri(queryString)
    uri = URI(YOUTUBE_SEARCH_LIST_ENDPOINT + queryString)
  end

  def build_query_string(search)
    query_string = '?key=AIzaSyD7AB8zljxcqkmLQlVtWmBUUEOwm6D98Es&part=id,snippet&maxResults=50&type=video&type=video&videoDuration=short&videoEmbeddable=true&videoSyndicated=true&videoLicense=creativeCommon&videoDefinition=high&q=' + search.text
  end

end