defmodule LiveMedia.Repo do
  use Ecto.Repo,
    otp_app: :live_media,
    adapter: Ecto.Adapters.Postgres
end
