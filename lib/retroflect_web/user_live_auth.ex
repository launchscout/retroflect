defmodule RetroflectWeb.UserLiveAuth do
  import Phoenix.LiveView

  alias Retroflect.Accounts

  @moduledoc """
  Module to add current user to session, or redirect to /users/log_in if not logged in
  """

  def mount(_params, %{"current_user_id" => user_id} = _session, socket) do
    socket =
      assign_new(socket, :current_user, fn ->
        Accounts.get_user!(user_id)
      end)

    if socket.assigns.current_user.confirmed_at do
      {:cont, socket}
    else
      {:halt, redirect(socket, to: "/users/log_in")}
    end
  end
end
