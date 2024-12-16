defmodule LiveMedia.Video do
  @moduledoc """
  Módulo para converter vídeos MP4 para MP3 usando FFmpeg.
  """

  @doc """
  Converte um arquivo MP4 em MP3.

  ## Parâmetros

    - `input_path`: Caminho para o arquivo de vídeo MP4.
    - `output_path`: Caminho para o arquivo de saída MP3.

  ## Exemplo

      iex> VideoToAudioConverter.convert("video.mp4", "audio.mp3")
      :ok

  """
  def to_audio(input_path, output_path) do
    case System.cmd("ffmpeg", ["-i", input_path, "-q:a", "0", "-map", "a", output_path]) do
      {_, 0} ->
        :ok

      {error_message, _exit_code} ->
        {:error, :directory_not_exist, error_message}
    end
  end
end
