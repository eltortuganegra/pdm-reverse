class YoutubeTrend < ActiveRecord::Base
  # belongs_to :youtube_trend_status
  has_one :youtube_trend_status
end