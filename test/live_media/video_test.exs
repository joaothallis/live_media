defmodule LiveMedia.VideoTest do
  use ExUnit.Case

  alias LiveMedia.Video

  describe "to_audio/2" do
    test "converter video to audio and delete audio file" do
      input_path = Path.join([File.cwd!(), "priv", "static", "uploads", "video.mp4"])
      output_path = Path.join([File.cwd!(), "priv", "static", "uploads", "audio.mp3"])

      Video.to_audio(input_path, output_path)

      assert File.exists?(output_path)
      assert File.rm(output_path) == :ok
    end

    test "return when path unexists" do
      input_path = ""
      output_path = ""

      assert {:error, :directory_not_exist, input_path} ==
               Video.to_audio(input_path, output_path)
    end
  end
end
