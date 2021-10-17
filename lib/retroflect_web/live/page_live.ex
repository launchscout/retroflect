defmodule RetroflectWeb.PageLive do
  use RetroflectWeb, :live_view
  on_mount RetroflectWeb.UserLiveAuth

  @moduledoc """
  Root live view
  """
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
