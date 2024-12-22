defmodule LiveMediaWeb.HomePageLive do
  use LiveMediaWeb, :live_view

  alias LiveMedia.Video

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:uploaded_files, [])
     |> allow_upload(:avatar, accept: ~w(.mp4), max_entries: 2)
     |> assign(:audio_path, nil)}
  end

  def render(assigns) do
    ~H"""
    <form id="upload-form" phx-submit="save" phx-change="validate">
      <.live_file_input upload={@uploads.avatar} />
      <button type="submit">Upload</button>
    </form>

    <%= if @audio_path do %>
      <p>Download do áudio convertido:</p>
      <a href={@audio_path} target="_blank">Baixar MP3</a>
    <% end %>
    <section phx-drop-target={@uploads.avatar.ref}>
      <%!-- render each avatar entry --%>
      <article :for={entry <- @uploads.avatar.entries} class="upload-entry">
        <figure>
          <.live_img_preview entry={entry} />
          <figcaption>{entry.client_name}</figcaption>
        </figure>

        <%!-- entry.progress will update automatically for in-flight entries --%>
        <progress value={entry.progress} max="100">{entry.progress}%</progress>

        <%!-- a regular click event whose handler will invoke Phoenix.LiveView.cancel_upload/3 --%>
        <button type="button" phx-click="cancel-upload" phx-value-ref={entry.ref} aria-label="cancel">
          &times;
        </button>

        <%!-- Phoenix.Component.upload_errors/2 returns a list of error atoms --%>
        <p :for={err <- upload_errors(@uploads.avatar, entry)} class="alert alert-danger">
          {error_to_string(err)}
        </p>
      </article>

      <%!-- Phoenix.Component.upload_errors/1 returns a list of error atoms --%>
      <p :for={err <- upload_errors(@uploads.avatar)} class="alert alert-danger">
        {error_to_string(err)}
      </p>
    </section>
    """
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
          audio_path =
            Path.join([File.cwd!(), "priv/static/uploads", "#{Ecto.UUID.generate()}.mp3"])

          case Video.to_audio(path, audio_path) do
            {:error, reason, _} -> {:error, reason}
            {:ok, _} = res -> res
          end
        end
      end)

    IO.inspect List.first(uploaded_files)
    {:noreply,
     update(socket, :uploaded_files, &(&1 ++ uploaded_files))
     |> update(:audio_path, List.first(uploaded_files))}
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
end
