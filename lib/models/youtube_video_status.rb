class YoutubeVideoStatus < ActiveRecord::Base
  PENDING_OF_PROCESS = 1
  IN_PROCESS = 2
  UPLOADED_TO_YOUTUBE = 3
end