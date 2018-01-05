class YoutubeVideoValidator

  def initialize youtube_video
    @youtube_video = youtube_video
    @keywords = Hash.new
  end

  def validate_keywords search
    Logger::debug 'does_it_contains_all_search_keywords_of_the_search'
    keywords = get_keywords_from_search(search)
    Logger::debug 'keywords: ' + search.text

    keywords.each { |keyword|
      Logger::debug 'Validation for search keyword: ' + keyword
      @keywords[keyword] = false
      check_if_keyword_is_in_some_field(keyword)
    }

    Logger::debug 'Check all keywords:'
    Logger::debug @keywords.inspect
    @keywords.each { |keyword, is_it_found|
      raise YoutubeVideoIsNotContainingAllKeywordsOfTheSearchException.new unless is_it_found
    }

  end

  private

  def get_keywords_from_search(search)
    search.text.split
  end

  def check_if_keyword_is_in_some_field(keyword)
    if is_keyword_in_title(keyword) || is_keyword_in_description(keyword) || is_keyword_in_tags(keyword)
      @keywords[keyword] = true
    end
  end

  def is_keyword_in_title(keyword)
    ! @youtube_video.title.index(keyword).nil?
  end

  def is_keyword_in_description(keyword)
    ! @youtube_video.description.index(keyword).nil?
  end

  def is_keyword_in_tags(keyword)
    ! @youtube_video.tags.index(keyword).nil?
  end

end