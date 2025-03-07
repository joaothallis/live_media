defmodule LiveMediaWeb.Live.HomePage do
  use LiveMediaWeb, :live_view

  alias LiveMedia.Video

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:uploaded_files, [])
     |> allow_upload(:avatar, accept: ~w(.mp4 .avi .mov .wmv), max_entries: 1)
     |> assign(:audio_path, nil)}
  end

  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :avatar, ref)}
  end

  def handle_event("save", _params, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :avatar, fn %{path: path}, _entry ->
        if path && File.exists?(path) do
          case Video.to_audio(path) do
            {:error, reason, _, _} -> {:error, reason}
            {:ok, _} = res -> res
          end
        end
      end)

    file_name = List.first(uploaded_files) |> String.split("/") |> List.last()

    {:noreply,
     assign(socket, :uploaded_files, &(&1 ++ uploaded_files))
     |> assign(:audio_path, "/uploads/#{file_name}")}
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
end
