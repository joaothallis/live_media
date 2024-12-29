defmodule LiveMedia.Video do
  @moduledoc """
  Module to convert MP4 videos to MP3 using FFmpeg.
  """

  @doc """
  Convert a video file to MP3.

  ## Parameters

    - `input_path`: Path to the video file.

  ## Example

      iex> VideoToAudioConverter.convert("video.mp4")
      :ok

  """
  def to_audio(input_path) do
    audio_path =
      Path.join(["./priv/static/uploads", "#{Ecto.UUID.generate()}.mp3"])

    case System.cmd("ffmpeg", ["-i", input_path, "-q:a", "0", "-map", "a?", audio_path]) do
      {_, 0} ->
        {:ok, audio_path}

      {error_message, exit_code} ->
        {:error, :conversion_failed, error_message, exit_code}
    end
  end
end
