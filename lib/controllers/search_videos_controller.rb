class SearchVideosController < Controller
  def run
    youtube_search = YoutubeSearch.new

    while (search = Search.get_query_with_older_last_search)
      Logger::debug 'Query string: ' + search.text
      Logger::debug 'Last search at: ' + search.last_search_at.inspect
      Logger::debug 'Time now: ' + Time.now.inspect
      Logger::debug 'One day ago: ' + 1.day.ago.inspect
      Logger::debug 'One day old?: ' + (!search.last_search_at.nil? && (search.last_search_at > 1.day.ago)).inspect

      if !search.last_search_at.nil? && (search.last_search_at > 1.day.ago)
        Logger::debug 'All searchs have been searched in the 24 previous hours.'

        break
      end

      search.last_search_at = Time.now
      search.save

      youtube_search_results = youtube_search.request search
      Logger::debug 'Total videos: ' + youtube_search_results.length.to_s
      Logger::debug youtube_search_results.inspect

      youtube_search_results.each do |youtube_search_result|
        Logger::debug ''
        Logger::debug 'youtube_search_result:'
        Logger::debug youtube_search_result.inspect
        youtube_video = YoutubeVideo.new(youtube_search_result.to_hash)

        parameters = {
          id: youtube_video.youtube_video_id
        }
        youtube_api_video_response = YoutubeApiVideo.get parameters
        YoutubeVideoTools.add_tags_from_youtube_api_video_reponse(youtube_video, youtube_api_video_response)

        begin
          youtube_video.save!
          validate_if_youtube_video_contains_all_keyword_of_the_search(search, youtube_video)
          Logger::debug 'This youtube_video has been saved successfully.'


        rescue ActiveRecord::RecordNotUnique
          Logger::debug 'Warning: This youtube_video has been saved before'
        rescue YoutubeVideoIsNotContainingAllKeywordsOfTheSearchException
          Logger::debug 'Warning: This video is not containig all keywords of the search'
          youtube_video.youtube_video_status_id = YoutubeVideoStatus::PENDING_OF_REVIEW_BECAUSE_IT_DOES_NOT_CONTAINS_ALL_KEYWORDS;
          youtube_video.save!
        rescue Exception => e
          Logger::debug 'Error: Video not saved!'
          Logger::debug "An error of type #{e.class} happened, message is #{e.message}"
          Logger::debug e.message
          Logger::debug e.backtrace.inspect
        end
      end

    end
  end

  def validate_if_youtube_video_contains_all_keyword_of_the_search(search, youtube_video)
    youtube_video_validator = YoutubeVideoValidator.new youtube_video
    unless youtube_video_validator.validate_keywords search
      Logger::debug 'This video has not contains all keywords of the search'
      Logger::debug 'Set this video like not valid for upload'

    end
  end
end
