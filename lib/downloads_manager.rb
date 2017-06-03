class DownloadsManager
  attr_accessor :config

  def initialize config
    @config = config
  end

  def download video
    # file_to_save = FileManager::get_downloaded_video_path(video.video_id)
    file_to_save = get_downloaded_video_path video.youtube_id

    File.open(file_to_save, "wb") do |saved_file|
      # the following "open" is provided by open-uri
      url_video = video.get_url_higher_resolution_video
      Logger::debug 'Url video: ' + url_video
      open(url_video, "rb") do |read_file|
        Logger::debug 'Saved file!'
        saved_file.write(read_file.read)
      end
    end

    File.exist? FileManager::get_downloaded_video_path(video.youtube_id)
  end

  def get_downloaded_video_path youtube_id
    @config.downloads_path + '/' + youtube_id
  end

end