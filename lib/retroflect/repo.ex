defmodule Retroflect.Repo do
  use Ecto.Repo,
    otp_app: :retroflect,
    adapter: Ecto.Adapters.Postgres
end
