class SearchVideosController < Controller

  def run
    youtube_search = YoutubeSearch.new

    while (search = Search::get_query_with_older_last_search)
      Logger::debug 'Query string: ' + search.text
      Logger::debug 'Last search at: ' + search.last_search_at.inspect
      Logger::debug 'Time now: ' + Time.now.inspect
      Logger::debug 'One day ago: ' + 1.day.ago.inspect
      Logger::debug 'One day old?: ' + (( ! search.last_search_at.nil?) && (search.last_search_at > 1.day.ago)).inspect

      if (( ! search.last_search_at.nil?) && (search.last_search_at > 1.day.ago))
        Logger::debug 'All searchs have been searched in the 24 previous hours.'

        break
      end

      search.last_search_at = Time.now
      search.save

      youtube_search_results = youtube_search.request search
      Logger::debug 'Total videos: ' + youtube_search_results.length.to_s
      Logger::debug youtube_search_results.inspect

      youtube_search_results.each { |youtube_search_result|
        Logger::debug ''
        Logger::debug 'youtube_search_result:'
        Logger::debug youtube_search_result.inspect
        youtube_video = YoutubeVideo.new(youtube_search_result.to_hash)

        parameters = {
            :id => youtube_video.youtube_video_id
        }
        youtube_api_video_response = YoutubeApiVideo::get parameters
        YoutubeVideoTools::add_tags_from_youtube_api_video_reponse(youtube_video, youtube_api_video_response)

        begin
          youtube_video.save!
          Logger::debug 'This youtube_video has been saved successfully.'
        rescue ActiveRecord::RecordNotUnique
          Logger::debug 'Warning: This youtube_video has been saved before'
        rescue Exception => e
          Logger::debug 'Error: Video not saved!'
          Logger::debug "An error of type #{e.class} happened, message is #{e.message}"
          Logger::debug e.message
          Logger::debug e.backtrace.inspect
        end
      }

    end
  end
end