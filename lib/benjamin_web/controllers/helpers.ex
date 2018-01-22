defmodule BenjaminWeb.Controller.Helpers do
    def assign_account(%Plug.Conn{assigns: %{user_account: user_account}}, params) do
        if Enum.all?(Map.keys(params), &is_atom/1) do
            Map.put(params, :account_id, user_account.id)
        else
            Map.put(params, "account_id", user_account.id)
        end
    end
end