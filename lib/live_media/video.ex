defmodule LiveMedia.Video do
  @moduledoc """
  Module to convert MP4 videos to MP3 using FFmpeg.
  """

  @doc """
  Convert a MP4 file to MP3.

  ## Parameters

    - `input_path`: Path to the MP4 file.
    - `output_path`: Path to the MP3 file.

  ## Example

      iex> VideoToAudioConverter.convert("video.mp4", "audio.mp3")
      :ok

  """
  def to_audio(input_path, output_path) do
    case System.cmd("ffmpeg", ["-i", input_path, "-q:a", "0", "-map", "a", output_path]) do
      {_, 0} ->
        {:ok, output_path}

      {error_message, _exit_code} ->
        {:error, :directory_not_exist, error_message}
    end
  end
end
