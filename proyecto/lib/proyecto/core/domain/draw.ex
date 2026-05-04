defmodule AzarSa.Core.Domain.Draw do
  @moduledoc """
  Constructor del dominio Sorteo.

  Campos:
  - id: identificador único (string)
  - name: nombre del sorteo
  - date: fecha programada (string ISO 8601, ej: "2026-06-01")
  - ticket_price: valor del billete completo en COP (entero)
  - fractions: número de fracciones por billete (ej: 10)
  - total_tickets: cantidad de billetes únicos disponibles (define el rango de números)
  - tickets: mapa número => %{client_id, fraction, bought_at}
  - prizes: lista de premios
  - status: :pending | :done
  - winning_number: nil o el número ganador (string)
  - result: nil o mapa con información del ganador
  - created_at: timestamp UTC en string
  """

  def new(id, name, date, ticket_price, fractions, total_tickets) do
    %{
      id: id,
      name: name,
      date: date,
      ticket_price: ticket_price,
      fractions: fractions,
      total_tickets: total_tickets,
      tickets: %{},
      prizes: [],
      status: :pending,
      winning_number: nil,
      result: nil,
      created_at: DateTime.utc_now() |> DateTime.to_string()
    }
  end
end
