class FileManager
  DOWNLOAD_FOLDER = 'downloads'

  def download_higher_resolution_video(video)
    file_to_save = FileManager::get_downloaded_video_path(video.youtube_id)
    File.open(file_to_save, "wb") do |saved_file|
      # the following "open" is provided by open-uri
      url_video = video.get_url_higher_resolution_video
      Logger::debug 'Url video: ' + url_video
      open(url_video, "rb") do |read_file|
      # open(url_video,  :allow_redirections => :all) do |read_file|
        Logger::debug 'Saved file!'
        saved_file.write(read_file.read)
      end
    end

    File.exist? FileManager::get_downloaded_video_path(video.youtube_id)
  end

  def self.get_downloaded_video_path(video_id)
    download_path = FileManager::DOWNLOAD_FOLDER + '/' + video_id
    Logger::debug 'get_downloaded_video_path: (' + download_path + ')'

    download_path
  end

  def self.get_downloaded_video_path_reversed(video_id)
    Dir.pwd + '/' + FileManager::DOWNLOAD_FOLDER + '/' + video_id + '.mp4'
  end

end