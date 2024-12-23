defmodule LiveMedia do
  @moduledoc """
  LiveMedia keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  def convert(input_path, output_path) do
    case System.cmd("ffmpeg", ["-i", input_path, "-q:a", "0", "-map", "a", output_path]) do
      {_, 0} ->
        :ok

      {error_message, _exit_code} ->
        {:error, error_message}
    end
  end
end
