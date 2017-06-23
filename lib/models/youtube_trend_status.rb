class YoutubeTrendStatus < ActiveRecord::Base
  self.table_name = "youtube_trends_statuses"

  has_many :youtube_trends

  PENDING_OF_PROCESS = 1
  IN_PROCESS = 2
  PROCESSED = 3
  FAIL_TO_REVERSE = 4
  FAIL_TO_DOWNLOAD = 5
  FAIL_TO_DOWNLOAD_BY_403_HTTP_CODE_STATUS = 6
  UPLOADED_TO_YOUTUBE = 7
end