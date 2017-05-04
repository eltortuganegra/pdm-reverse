class FileManager
  DOWNLOAD_FOLDER = 'downloads'

  def download_higher_resolution_video(video_data_for_download, video_id)
    File.open(get_downloaded_video_path(video_id), "wb") do |saved_file|
      # the following "open" is provided by open-uri
      open(video_data_for_download['url'], "rb") do |read_file|
        Logger::debug 'Saved file!'
        saved_file.write(read_file.read)
      end
    end

    File.exist? get_downloaded_video_path(video_id)
  end

  def get_downloaded_video_path(video_id)
    Application::DOWNLOAD_FOLDER + '/' + video_id
  end
end