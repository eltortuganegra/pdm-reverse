require 'rubygems'
require 'google/apis/youtube_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'net/http'
require 'active_record'
require 'cgi'
require 'open-uri'
require 'open_uri_redirections'
require 'cgi'
require 'net/http'
require 'json'



require_relative './lib/logger'
require_relative './lib/models/model'
require_relative './lib/models/youtube_video'
require_relative './lib/models/search'
require_relative './lib/youtube_api/youtube_api_get_video_info'
require_relative './lib/youtube_search'
require_relative './lib/youtube_search_result'
require_relative './lib/youtube_search_result'


puts '***************************'
puts 'Search videos'
puts '***************************'

youtube_search = YoutubeSearch.new


def addTags(youtube_video, youtube_video_info)
  if youtube_video_info.key?('keywords') && !youtube_video_info['keywords'].nil? && youtube_video_info['keywords'][0] != ""
    youtube_video.tags = youtube_video_info['keywords'].join(", ") + ', reverse,funny'
  else
    youtube_video.tags = 'reverse,funny'
  end
end

while (search = Search::get_query_with_older_last_search)
  Logger::debug 'Query string: ' + search.text
  Logger::debug 'Last search at: ' + search.last_search_at.inspect
  Logger::debug 'Time now: ' + Time.now.inspect
  Logger::debug 'One day ago: ' + 1.day.ago.inspect
  Logger::debug 'One day old?: ' + (! search.last_search_at.nil? && search.last_search_at > 1.day.ago).inspect

  if ( ! search.last_search_at.nil? && search.last_search_at > 1.day.ago)
    puts 'All searchs have been searched in the 24 previous hours.'
    break;
  end

  youtube_search_results = youtube_search.request search
  puts 'Total videos: ' + youtube_search_results.length.to_s
  puts youtube_search_results.inspect

  youtube_search_results.each { |youtube_search_result|
    puts ''
    puts 'youtube_search_result:'
    puts youtube_search_result.inspect
    youtube_video = YoutubeVideo.new(youtube_search_result.to_hash)
    youtube_video_info = YoutubeApiGetVideoInfo::submit youtube_search_result.youtube_video_id
    addTags(youtube_video, youtube_video_info)

    begin
      youtube_video.save!
      puts 'This youtube_video has been saved successfully.'
    rescue ActiveRecord::RecordNotUnique
      puts 'Warning: This youtube_video has been saved before'
    rescue Exception => e
      puts 'Error: Video not saved!'
      puts "An error of type #{e.class} happened, message is #{e.message}"
      puts e.message
      puts e.backtrace.inspect
    end
  }

end