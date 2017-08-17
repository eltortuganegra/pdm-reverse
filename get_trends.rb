require 'rubygems'
require 'google/apis/youtube_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'net/http'
require 'active_record'

require_relative './lib/youtube_manager'
require_relative './lib/models/model'
require_relative './lib/models/youtube_trend'
require_relative './lib/models/country'

puts '***************************'
puts 'Test for save trends to db'
puts '***************************'

# countries = Country.select('id, alpha2_code').all
# puts countries.inspect
#
# puts ''
# countries.each do |country|
#   puts 'Country' + country.id.to_s + ' country code ' + country.alpha2_code
# end
#
# abort()



youtube_manager = YoutubeManager.new 'asdf'
video_list = youtube_manager.getTrends


puts "\n ------- Videos"
puts "Total " + video_list.length.to_s

def convertToSeconds(duration)
  pattern = "PT"
  pattern += "%HH" if duration.include? "H"
  pattern += "%MM" if duration.include? "M"
  pattern += "%SS" if duration.include? "S"

  puts "ConverToSeconds pattern: " + pattern

  DateTime.strptime(duration, pattern).seconds_since_midnight.to_i
end

video_list.each do |video_data|
  puts "\nVideo data: "
  puts video_data.inspect


  youtube_trend = YoutubeTrend.find_by(youtube_id: video_data['id'])
  puts "checking if trend is saved"
  if ! youtube_trend.nil?
    puts 'This video is saved'

    next
  end

  puts "this video is not saved yet"

  if ! video_data.key? ('contentDetails')
    puts 'this video has not contentDetails'

    next
  end

  puts "\nSaving trend:"
  puts video_data.inspect
  youtube_trend = YoutubeTrend.new
  youtube_trend.youtube_id = video_data['id']
  youtube_trend.etag = video_data['etag']
  youtube_trend.licensed_content = video_data['contentDetails']['licensedContent']
  youtube_trend.duration = video_data['contentDetails']['duration']
  youtube_trend.duration_in_seconds = convertToSeconds(video_data['contentDetails']['duration'])
  youtube_trend.dimension = video_data['contentDetails']['dimension']
  youtube_trend.definition = video_data['contentDetails']['definition']
  youtube_trend.caption = video_data['contentDetails']['caption']
  youtube_trend.projection = video_data['contentDetails']['projection']
  youtube_trend.published_at = video_data['snippet']['publishedAt']
  youtube_trend.channel_id = video_data['snippet']['channelId']
  youtube_trend.title = video_data['snippet']['title']
  youtube_trend.description = video_data['snippet']['description']
  youtube_trend.channel_title = video_data['snippet']['channelTitle']
  if video_data['snippet'].key?('tags')
    youtube_trend.tags = video_data['snippet']['tags'].join(',')
  end
  youtube_trend.category_id = video_data['snippet']['categoryId']
  youtube_trend.live_broadcast_content = video_data['snippet']['liveBroadcastContent']
  youtube_trend.default_language = video_data['snippet']['defaultLanguage']
  youtube_trend.localized_title = video_data['snippet']['localized']['title']
  youtube_trend.localized_description = video_data['snippet']['localized']['description']
  youtube_trend.default_audio_language = video_data['snippet']['defaultAudioLanguage']

  begin
    youtube_trend.save
  rescue ActiveRecord::StatementInvalid => e
    puts 'Exception:' + e.message
  end
end
