class YoutubeVideo < ActiveRecord::Base

  def self.get_youtube_video_with_newest_publication_date
    YoutubeVideo
        .where(youtube_video_status_id: YoutubeVideoStatus::PENDING_OF_PROCESS)
        .order(published_at: :asc)
        .limit(1)
        .first
  end
end