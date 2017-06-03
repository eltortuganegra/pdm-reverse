class ConverterManager
  attr_accessor :config
  def initialize config
    @config = config
  end

  def convert video
    if ! system(get_reverse_video_command video.youtube_id)
      Logger::debug 'video is not reverse'
      return false
    end

    Logger::debug 'Video is converted'
    return true
  end

  def get_reverse_video_command youtube_id
    input_file = getInputFilePath youtube_id
    output_file = getOutputFilePath youtube_id
    command = "ffmpeg -i " + input_file + " -vf \"reverse,hflip\" -af areverse " + output_file
    Logger::debug 'get_reverse_video_command:'
    Logger::debug command

    command
  end

  def getInputFilePath youtube_id
    @config.downloads_path + '/' + youtube_id
  end

  def getOutputFilePath youtube_id
    @config.downloads_path + '/' + youtube_id + '.mp4'
  end


end