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
    <div class="max-w-4xl mx-auto mt-10 p-4 bg-white shadow rounded-lg">
      <form id="upload-form" phx-submit="save" phx-change="validate" class="space-y-4">
        <div class="flex items-center justify-center w-full" phx-drop-target={@uploads.avatar.ref}>
          <label
            for="dropzone-file"
            class="flex flex-col items-center justify-center w-full h-64 border-2 border-gray-300 border-dashed rounded-lg cursor-pointer bg-gray-50 dark:hover:bg-gray-800 dark:bg-gray-700 hover:bg-gray-100 dark:border-gray-600 dark:hover:border-gray-500 dark:hover:bg-gray-600"
          >
            <div class="flex flex-col items-center justify-center pt-5 pb-6">
              <svg
                class="w-8 h-8 mb-4 text-gray-500 dark:text-gray-400"
                aria-hidden="true"
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 20 16"
              >
                <path
                  stroke="currentColor"
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M13 13h3a3 3 0 0 0 0-6h-.025A5.56 5.56 0 0 0 16 6.5 5.5 5.5 0 0 0 5.207 5.021C5.137 5.017 5.071 5 5 5a4 4 0 0 0 0 8h2.167M10 15V6m0 0L8 8m2-2 2 2"
                />
              </svg>
              <p class="mb-2 text-sm text-gray-500 dark:text-gray-400">
                <span class="font-semibold">Click to upload</span> or drag and drop
              </p>
              <p class="text-xs text-gray-500 dark:text-gray-400">
                SVG, PNG, JPG or GIF (MAX. 800x400px)
              </p>
            </div>
            <.live_file_input id="dropzone-file" upload={@uploads.avatar} />
          </label>
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700">Upload MP4</label>
        </div>
        <button
          type="submit"
          class="w-full inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
        >
          Upload
        </button>
      </form>

      <%= if @audio_path do %>
        <div class="mt-6 bg-green-50 border-l-4 border-green-400 p-4">
          <p class="text-sm text-green-800">Download do áudio convertido:</p>
          <a href={@audio_path} download class="text-indigo-600 hover:text-indigo-900 underline">
            Baixar MP3
          </a>
        </div>
      <% end %>

      <section phx-drop-target={@uploads.avatar.ref} class="mt-6">
        <article :for={entry <- @uploads.avatar.entries} class="bg-gray-50 p-4 rounded-lg shadow mb-4">
          <div class="flex items-center">
            <figure class="flex-shrink-0 mr-4">
              <.live_img_preview entry={entry} class="w-16 h-16 rounded-md shadow" />
            </figure>
            <div>
              <figcaption class="text-sm font-medium text-gray-700">{entry.client_name}</figcaption>
              <progress
                value={entry.progress}
                max="100"
                class="w-full mt-1 h-2 bg-gray-200 rounded-full overflow-hidden"
              >
                {entry.progress}%
              </progress>
            </div>
            <button
              type="button"
              phx-click="cancel-upload"
              phx-value-ref={entry.ref}
              aria-label="cancel"
              class="ml-auto inline-flex items-center px-2 py-1 border border-transparent text-sm font-medium rounded text-red-600 hover:bg-red-100 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500"
            >
              &times;
            </button>
          </div>

          <p :for={err <- upload_errors(@uploads.avatar, entry)} class="mt-2 text-sm text-red-600">
            {error_to_string(err)}
          </p>
        </article>

        <p :for={err <- upload_errors(@uploads.avatar)} class="text-sm text-red-600">
          {error_to_string(err)}
        </p>
      </section>
    </div>
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
        IO.inspect(File.cwd!(),label: "UPLOAD_TEST")
        if path && File.exists?(path) do
          audio_path =
            Path.join(["./priv/static/uploads", "#{Ecto.UUID.generate()}.mp3"])

          case Video.to_audio(path, audio_path) do
            {:error, reason, _} -> {:error, reason}
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
