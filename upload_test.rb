require 'yt'
require 'open-uri'
require 'net/http'

# Yt.configure do |config|
#   config.log_level = :debug
# end
#
# Yt.configuration.api_key = "AIzaSyDu_K050qbIQQnw3ZJ2MTLS1lYssdh_B6E" ## replace with your API key

# video = Yt::Video.new id: 'HtOFVF7Cr4k'     ## use any public video ID
# puts video.id
# puts video.title
# puts video.description
# puts video.published_at
# puts video.thumbnail_url
# puts video.channel_title
# puts video.category_title
# puts video.tags.inspect
# puts video.duration # => 321
# puts video.length # => "05:21"
# puts video.stereoscopic? # => false
# puts video.hd? # => false
# puts video.captioned? # => true
# puts video.licensed? # => false
# puts video.age_restricted? # => false
# # puts video.file_size # => 8000000
# # puts video.file_type # => "video"
# # puts video.container # => "mov"




# Yt.configure do |config|
#   config.client_id = '49781862760-4t610gtk35462g.apps.googleusercontent.com'
#   config.client_secret = 'NtFHjZkJcwYZDfYVz9mp8skz9'
#   config.log_level = :debug
# end

# test
Yt.configure do |config|
  config.client_id = '426846052314-ul3u5fukses4qelqcpd6lr0h430r7s65.apps.googleusercontent.com'
  config.client_secret = '9qpmjnkFaUGencEfAmrQeXlY'
  config.log_level = :debug
end
# Yt.configuration.client_id = "426846052314-c00tio44fsio8ogt8jvs52qvflb1qbbt.apps.googleusercontent.com"
# Yt.configuration.client_secret = "mce4UoGIMfxt8e9AgeRRrt5K"

redirect_uri = 'http://localhost'

scopes = ['youtube.upload']
# url = Yt::Account.new(scopes: scopes, redirect_uri: redirect_uri).authentication_url
# puts 'Authentication url: '
# puts url.inspect
# puts ''

#
# puts 'Get url'
# source = open(url).read
# # puts source
# puts ''

# puts 'Send form for permit'
# postUrl = 'https://accounts.google.com/o/oauth2/approval?as=-465bf2350b816c9&pageId=none&xsrfsign=AOq_MukAAAAAWRte2JNQY28Q6nHGCtPhw3ETqqnwzLNm'
# postData = {
#     '_utf8' => '☃',
#     'bgresponse' => '',
#     'state_wrapper' => 'CnohQ2hSNk1VMUVRblZSYmtwM2VYRjFkWEV6VmtaTUxSSWZjemxWTUhsaGFGWkJPV3RTTUVGdlZFOTRkalJmYldkaGNWUlZkWGRTVlHiiJlBRGlJR3lFQUFBQUFXUnl1aEc5dWlEWlV4b1AzRmh0LUZ1MDFyOGt3aDR1MhIVMTE1MjM0Njk2OTYxNjIzMTk3MjcyGKGKreTvrYvkVQ',
#     'submit_access' => true
# }
#
# postResponse = Net::HTTP.post_form(URI.parse(postUrl), postData)
# puts postResponse.inspect
#
# exit
#
#
authorization_code = '4/9XFGyg5FMTaN-ctefSskMxg5phx1f9wUviQn_xuneX0#'
account = Yt::Account.new authorization_code: authorization_code, redirect_uri: redirect_uri



# puts 'Account data'
# puts account.email

# Uploading a video
puts 'Uploading video'
result = account.upload_video "downloads/R2u822BzQw8-reversed.mov", title: "prueba 3", privacy_status: "private"
puts result.inspect


# account = Yt::Account.new refresh_token: authorization_code
# puts account.inspect

