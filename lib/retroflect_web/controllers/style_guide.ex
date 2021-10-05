defmodule RetroflectWeb.StyleGuideController do
  use RetroflectWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
