defmodule RetroflectWeb.UserLiveAuth do
  import Phoenix.LiveView

  alias Retroflect.Accounts

  @moduledoc """
  Module to add current user to session, or redirect to /users/log_in if not logged in
  """

  def mount(params, %{"user_token" => user_token} = _session, socket) do
    socket =
      assign_new(socket, :current_user, fn ->
        Accounts.get_user_by_session_token(user_token)
      end)

    if socket.assigns.current_user do
      {:cont, socket}
    else
      {:halt, redirect(socket, to: "/users/log_in")}
    end
  end
end
