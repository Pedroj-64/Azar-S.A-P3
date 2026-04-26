defmodule AzarServer.ContextCase do
  @moduledoc """
  Helper para tests de contextos (Operations).

  Proporciona setup y helpers comunes para tests.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      import AzarServer.ContextCase
    end
  end

  @doc """
  Helper para crear datos de test.
  """
  def fixture(type, attrs \\ %{})

  def fixture(:draw, attrs) do
    Map.merge(
      %{
        name: "Test Draw",
        draw_date: DateTime.utc_now() |> DateTime.add(3600),
        full_ticket_value: 10000,
        fractions_count: 10,
        total_tickets: 100,
        user_id: "admin-123",
        user_name: "Admin Test"
      },
      attrs
    )
  end

  def fixture(:ticket, attrs) do
    Map.merge(
      %{
        number: "001",
        draw_id: "draw-123",
        ticket_type: "complete",
        owner: nil,
        owner_name: nil,
        purchase_price: 0
      },
      attrs
    )
  end
end
