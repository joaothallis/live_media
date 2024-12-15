defmodule LiveMediaWeb.HomePageLive do
  use LiveMediaWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:uploaded_files, [])
     |> allow_upload(:avatar, accept: ~w(.jpg .jpeg), max_entries: 2)}
  end

  def render(assigns) do
    ~H"""
    <form id="upload-form" phx-submit="save" phx-change="validate">
      <.live_file_input upload={@uploads.avatar} />
      <button type="submit">Upload</button>
    </form>
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
        dest = Path.join([:code.priv_dir(:live_media), "static", "uploads", Path.basename(path)])
        # You will need to create `priv/static/uploads` for `File.cp!/2` to work.
        File.cp!(path, dest)
        {:ok, ~p"/uploads/#{Path.basename(dest)}"}
      end)

    {:noreply, update(socket, :uploaded_files, &(&1 ++ uploaded_files))}
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
end
