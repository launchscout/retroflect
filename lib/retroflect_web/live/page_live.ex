defmodule RetroflectWeb.PageLive do
  use RetroflectWeb, :live_view
  on_mount RetroflectWeb.UserLiveAuth

  def mount(_params, session, socket) do
    {:ok, socket}
  end
end
