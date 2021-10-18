defmodule RetroflectWeb.PageLive do
  use RetroflectWeb, :live_view

  @moduledoc """
  Root live view
  """
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
