require 'rubygems'
require 'google/apis/youtube_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'net/http'
require 'active_record'

require_relative './lib/models/model'
require_relative './lib/models/youtube_video'
require_relative './lib/youtube_search'
require_relative './lib/youtube_search_result'


puts '***************************'
puts 'Search videos'
puts '***************************'

youtube_search = YoutubeSearch.new
youtube_search_results = youtube_search.search

puts 'Total videos: ' + youtube_search_results.length.to_s
puts youtube_search_results.inspect

youtube_search_results.each { |youtube_search_result|
  puts ''
  puts 'youtube_search_result:'
  puts youtube_search_result.inspect
  youtube_video = YoutubeVideo.new(youtube_search_result.to_hash)
  youtube_video.tags = 'reverse,funny'
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





