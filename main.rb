# require 'open-uri'
# require 'cgi'
# require 'net/http'
#
# def tube(id)
#   'http://youtube.com/get_video_info?video_id=' + id
# end
#
# def get_video_data(id)
#   CGI.parse open(tube(id)).read
# end
#
# def get_video_streams(id)
#   streams = get_video_data(id)['url_encoded_fmt_stream_map'].first.split(',')
#   streams.map do |s|
#     x = CGI.parse s
#     x.each do |k,v|
#       if k == 'type'
#         x[k] = v.first.split('; ')
#       else
#         x[k] = v.first
#       end
#     end
#   end
# end
#
#
# # Get Videos
#
# video_id = "ekz-FY_MDGA"
# streams  = get_video_streams(video_id)
#
# puts "### Total #{streams.count} streams available:\n\n"
#
# def saveVideo(i, s)
#   File.open("Stream #{i+1}", "wb") do |saved_file|
#     # the following "open" is provided by open-uri
#     open(s['url'], "rb") do |read_file|
#       puts 'Saved file!'
#       #saved_file.write(read_file.read)
#       saved_file.write('JSF')
#     end
#   end
# end
#
# streams.each_with_index do |s,i|
#   puts "Stream #{i+1}",
#        "-------------",
#        "Quality: #{s['quality']}",
#        "Type: #{s['type'].first}",
#        "URL:  #{s['url']} \n\n"
#
#   exec_command = "echo \"Stream #{i+1}\" >> app.log "
#   system exec_command
#   #saveVideo(i, s)
# end

require './lib/application'

application = Application.new
application.run


