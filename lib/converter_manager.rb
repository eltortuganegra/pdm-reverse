class ConverterManager
  attr_accessor :config
  def initialize config
    @config = config
  end

  def convert youtube_video
    if ! system(get_reverse_video_command youtube_video.youtube_video_id)
      raise VideoHasNotBeenReversed.new
    end

    Logger::debug 'Video is converted'

    return true
  end

  def get_reverse_video_command youtube_video_id
    input_file = getInputFilePath youtube_video_id
    output_file = getOutputFilePath youtube_video_id
    command = "ffmpeg -i " + input_file + " -vf \"reverse,hflip\" -af areverse " + output_file
    Logger::debug 'get_reverse_video_command:'
    Logger::debug command

    command
  end

  def getInputFilePath youtube_video_id
    @config.downloads_path + '/' + youtube_video_id
  end

  def getOutputFilePath youtube_video_id
    @config.downloads_path + '/' + youtube_video_id + '.mp4'
  end


end