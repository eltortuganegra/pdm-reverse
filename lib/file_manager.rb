class FileManager
  DOWNLOAD_FOLDER = 'downloads'

  def download_higher_resolution_video(video)
    file_to_save = FileManager::get_downloaded_video_path(video.video_id)
    File.open(file_to_save, "wb") do |saved_file|
      # the following "open" is provided by open-uri
      url_video = video.get_url_higher_resolution_video
      open(url_video, "rb") do |read_file|
        Logger::debug 'Saved file!'
        saved_file.write(read_file.read)
      end
    end

    File.exist? FileManager::get_downloaded_video_path(video.video_id)
  end

  def self.get_downloaded_video_path(video_id)
    FileManager::DOWNLOAD_FOLDER + '/' + video_id
  end

  def self.get_downloaded_video_path_reversed(video_id)
    FileManager::DOWNLOAD_FOLDER + '/' + video_id + '-reversed.mov'
  end
end