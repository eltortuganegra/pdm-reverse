require 'open-uri'
require 'cgi'
require 'net/http'

class Application
  YOUTUBE_INFO_URI= 'http://youtube.com/get_video_info?video_id='

  def run
    video_id = "R2u822BzQw8"
    video_data = get_video_data video_id
    puts 'Video data:'
    puts video_data

    puts ''
    puts 'Get video streams'
    streams = get_video_streams video_data
    puts streams.inspect

    video_data_for_download = nil
    for video_data_quality in streams
      puts "-------------",
           "Quality: #{video_data_quality['quality']}",
           "Type: #{video_data_quality['type'].first}",
           "URL:  #{video_data_quality['url']} \n\n"
      if video_data_for_download.nil? || (checkIfResolutionIsHigher video_data_for_download, video_data_quality)
        puts 'Set this video'
        video_data_for_download = video_data_quality
      end
    end

    puts 'Video with the higher resolution'
    puts video_data_for_download.inspect
    puts

    File.open('downloads/' + video_id, "wb") do |saved_file|
      # the following "open" is provided by open-uri
      open(video_data_for_download['url'], "rb") do |read_file|
        puts 'Saved file!'
        saved_file.write(read_file.read)
      end
    end

    if File.exist? 'downloads/' + video_id
      puts 'File exist'

      if system( get_reverse_video_command video_id )
        puts 'video is reverse'
      else
        puts 'video is not reverse'
      end
    else
      puts 'File does not exist'
    end

  end

  def checkIfResolutionIsHigher(video_data_for_download, video_data_quality)

    return (video_data_for_download['quality'] === 'hd1080') ||
       (video_data_for_download['quality'] === 'hd720' && video_data_quality['quality'] == 'hd1080') ||
       (video_data_for_download['quality'] === 'large' && (video_data_quality['quality'] === 'hd1080' || video_data_quality['quality'] === 'hd720')) ||
       (video_data_for_download['quality'] === 'medium' && (video_data_quality['quality'] === 'hd1080' || video_data_quality['quality'] === 'hd720' || video_data_quality['quality'] === 'large')) ||
       (video_data_for_download['quality'] === 'small' && (video_data_quality['quality'] === 'hd1080' || video_data_quality['quality'] === 'hd720' || video_data_quality['quality'] === 'large' || video_data_quality['quality'] === 'medium'))
  end

  def get_info_video_uri(video_id)
     Application::YOUTUBE_INFO_URI + video_id
  end

  def get_video_data(video_id)
    CGI.parse open(get_info_video_uri(video_id)).read
  end

  def get_video_streams(video_data)
    streams = video_data['url_encoded_fmt_stream_map'].first.split(',')
    streams.map do |s|
      x = CGI.parse s
      x.each do |k,v|
        if k == 'type'
          x[k] = v.first.split('; ')
        else
          x[k] = v.first
        end
      end
    end
  end

  def get_reverse_video_command video_id
    'ffmpeg -i ./downloads/' + video_id + ' -vf "reverse,hflip" -af areverse ./downloads/' + video_id + '-reversed.mp4'
  end

end


