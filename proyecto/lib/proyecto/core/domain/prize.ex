defmodule AzarSa.Core.Domain.Prize do
  @moduledoc """
  Constructor del dominio Premio.

  Campos:
  - id: identificador único (string hex)
  - name: nombre del premio (ej: "Gran Premio", "Segundo Lugar")
  - amount: valor monetario en COP (entero)
  - created_at: timestamp UTC en string
  """

  def new(name, amount) do
    %{
      "id" => :crypto.strong_rand_bytes(4) |> Base.encode16(),
      "name" => name,
      "amount" => amount,
      "created_at" => DateTime.utc_now() |> DateTime.to_string()
    }
  end
end
