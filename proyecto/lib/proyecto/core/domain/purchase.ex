defmodule AzarSa.Core.Domain.Purchase do
  @moduledoc """
  Constructor del dominio Compra (ticket adquirido).

  Campos:
  - client_id: identificador del cliente comprador
  - number: número del billete (string)
  - fraction: "full" o el número de fracción (string)
  - bought_at: timestamp UTC en string
  """

  def new(client_id, number, fraction) do
    %{
      "client_id" => client_id,
      "number" => to_string(number),
      "fraction" => fraction_label(fraction),
      "bought_at" => DateTime.utc_now() |> DateTime.to_string()
    }
  end

  defp fraction_label(:full), do: "full"
  defp fraction_label(n), do: to_string(n)
end
