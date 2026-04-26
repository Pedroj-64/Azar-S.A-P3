defmodule AzarPlayer.Controllers.PurchaseController do
  @moduledoc """
  Controller para gestión de compras de billetes.

  Proporciona endpoints para:
  - Crear nuevas compras (billetes completos o fracciones)
  - Listar historial de compras del usuario
  - Obtener detalles de una compra específica
  - Devolver/cancelar una compra
  - Listar reembolsos del usuario
  - Listar compras por sorteo
  - Calcular precio de compra
  - Ver compras ganadoras
  """

  use Phoenix.Controller

  alias AzarPlayer.Contexts.Purchases.Operations, as: PurchaseOps
  alias AzarPlayer.Contexts.Users.Operations, as: UserOps
  alias AzarShared.Errors

  @doc """
  Crea una nueva compra de billetes.

  Parámetros esperados:
  - draw_id: String (ID del sorteo)
  - purchase_type: String ("complete" o "fraction")
  - ticket_number: Integer (1-10000)
  - fraction_number: Integer (1-100, solo si purchase_type="fraction")
  - quantity: Integer (cantidad de billetes/fracciones)

  Retorna:
  - 201 Created: Compra creada exitosamente
  - 400 Bad Request: Validación fallida
  - 409 Conflict: Fondos insuficientes o sorteo no disponible
  """
  def create(conn, %{"purchase" => purchase_params}) do
    user_id = conn.assigns[:current_user_id]
    params_with_user = Map.put(purchase_params, "user_id", user_id)

    # Validar que el usuario tenga saldo suficiente
    case UserOps.get_balance(user_id) do
      {:ok, balance} ->
        # Calcular precio
        case calculate_and_validate_purchase(params_with_user, balance) do
          {:ok, price_breakdown} ->
            # Crear la compra
            case PurchaseOps.create_purchase(params_with_user) do
              {:ok, purchase} ->
                # Debitar saldo
                case UserOps.debit_balance(user_id, price_breakdown.total_price, "Purchase of ticket #{purchase.ticket_number}") do
                  {:ok, _balance} ->
                    conn
                    |> put_status(:created)
                    |> json(%{
                      status: "ok",
                      message: "Purchase created successfully",
                      purchase: format_purchase_response(purchase, price_breakdown)
                    })

                  {:error, reason} ->
                    conn
                    |> put_status(:conflict)
                    |> json(%{
                      status: "error",
                      message: "Failed to debit balance: #{reason}"
                    })
                end

              {:error, reason} ->
                conn
                |> put_status(:bad_request)
                |> json(%{
                  status: "error",
                  message: reason
                })
            end

          {:error, reason} ->
            conn
            |> put_status(:conflict)
            |> json(%{
              status: "error",
              message: reason
            })
        end

      {:error, reason} ->
        conn
        |> put_status(:not_found)
        |> json(%{
          status: "error",
          message: reason
        })
    end
  end

  @doc """
  Lista todas las compras del usuario autenticado.

  Parámetros:
  - status: String (opcional: "pending", "executed", "returned")
  - page: Integer (default: 1)
  - limit: Integer (default: 20, máximo 100)

  Retorna:
  - 200 OK: Lista paginada de compras
  """
  def list_user_purchases(conn, params) do
    user_id = conn.assigns[:current_user_id]
    _status = params["status"]
    page = String.to_integer(params["page"] || "1")
    limit = String.to_integer(params["limit"] || "20") |> min(100)

    case PurchaseOps.list_user_purchases(user_id) do
      {:ok, purchases} ->
        paginated = paginate_list(purchases, page, limit)

        json(conn, %{
          status: "ok",
          purchases: paginated,
          page: page,
          limit: limit,
          total: Enum.count(purchases)
        })

      {:error, reason} ->
        conn
        |> put_status(:not_found)
        |> json(%{
          status: "error",
          message: reason
        })
    end
  end

  @doc """
  Obtiene detalles de una compra específica.

  Parámetros:
  - id: String (ID de la compra)

  Retorna:
  - 200 OK: Detalles de la compra
  - 404 Not Found: Compra no existe
  - 403 Forbidden: Usuario no tiene permiso para ver esta compra
  """
  def get_purchase(conn, %{"id" => purchase_id}) do
    user_id = conn.assigns[:current_user_id]

    case PurchaseOps.get_purchase(purchase_id) do
      {:ok, purchase} ->
        if purchase.user_id == user_id do
          json(conn, %{
            status: "ok",
            purchase: purchase
          })
        else
          conn
          |> put_status(:forbidden)
          |> json(%{
            status: "error",
            message: "Access denied"
          })
        end

      {:error, reason} ->
        conn
        |> put_status(:not_found)
        |> json(%{
          status: "error",
          message: reason
        })
    end
  end

  @doc """
  Devuelve/cancela una compra (solicita reembolso).

  Parámetros:
  - purchase_id: String
  - reason: String (motivo de la devolución)

  Retorna:
  - 200 OK: Devolución procesada
  - 400 Bad Request: Compra no puede ser devuelta
  - 404 Not Found: Compra no existe
  """
  def return_purchase(conn, %{"purchase_id" => purchase_id, "reason" => reason}) do
    user_id = conn.assigns[:current_user_id]

    # Verificar que la compra pertenece al usuario
    case PurchaseOps.get_purchase(purchase_id) do
      {:ok, purchase} ->
        if purchase.user_id != user_id do
          conn
          |> put_status(:forbidden)
          |> json(%{
            status: "error",
            message: "Access denied"
          })
        else
          # Procesar la devolución
          case PurchaseOps.return_purchase(purchase_id, reason) do
            {:ok, refund} ->
              # Acreditar saldo
              case UserOps.credit_balance(user_id, refund.refund_amount, "Refund for purchase #{purchase_id}") do
                {:ok, _balance} ->
                  json(conn, %{
                    status: "ok",
                    message: "Purchase returned successfully",
                    refund: refund
                  })

                {:error, balance_error} ->
                  conn
                  |> put_status(:internal_server_error)
                  |> json(%{
                    status: "error",
                    message: "Refund created but failed to credit balance: #{balance_error}"
                  })
              end

            {:error, reason} ->
              conn
              |> put_status(:bad_request)
              |> json(%{
                status: "error",
                message: reason
              })
          end
        end

      {:error, reason} ->
        conn
        |> put_status(:not_found)
        |> json(%{
          status: "error",
          message: reason
        })
    end
  end

  @doc """
  Lista los reembolsos del usuario.

  Parámetros:
  - status: String (opcional: "pending", "processed")
  - page: Integer (default: 1)
  - limit: Integer (default: 20)

  Retorna:
  - 200 OK: Lista de reembolsos
  """
  def list_refunds(conn, params) do
    user_id = conn.assigns[:current_user_id]
    page = String.to_integer(params["page"] || "1")
    limit = String.to_integer(params["limit"] || "20") |> min(100)

    case PurchaseOps.list_refunds_by_user(user_id) do
      {:ok, refunds} ->
        paginated = paginate_list(refunds, page, limit)

        json(conn, %{
          status: "ok",
          refunds: paginated,
          page: page,
          limit: limit,
          total: Enum.count(refunds)
        })

      {:error, reason} ->
        conn
        |> put_status(:not_found)
        |> json(%{
          status: "error",
          message: reason
        })
    end
  end

  @doc """
  Lista las compras ganadoras del usuario.

  Retorna:
  - 200 OK: Lista de compras que ganaron premios
  """
  def list_winning_purchases(conn, params) do
    user_id = conn.assigns[:current_user_id]
    page = String.to_integer(params["page"] || "1")
    limit = String.to_integer(params["limit"] || "20") |> min(100)

    case PurchaseOps.list_winning_purchases(user_id) do
      {:ok, winning_purchases} ->
        paginated = paginate_list(winning_purchases, page, limit)

        json(conn, %{
          status: "ok",
          winning_purchases: paginated,
          page: page,
          limit: limit,
          total: Enum.count(winning_purchases)
        })

      {:error, reason} ->
        conn
        |> put_status(:not_found)
        |> json(%{
          status: "error",
          message: reason
        })
    end
  end

  @doc """
  Obtiene estadísticas de compras del usuario.

  Retorna:
  - 200 OK: Estadísticas generales de compras
  """
  def get_statistics(conn, _params) do
    user_id = conn.assigns[:current_user_id]

    case PurchaseOps.get_purchase_statistics(user_id) do
      {:ok, stats} ->
        json(conn, %{
          status: "ok",
          statistics: stats
        })

      {:error, reason} ->
        conn
        |> put_status(:not_found)
        |> json(%{
          status: "error",
          message: reason
        })
    end
  end

  # Helpers

  defp calculate_and_validate_purchase(params, balance) do
    draw_id = params["draw_id"]
    ticket_number = params["ticket_number"]
    fraction_number = params["fraction_number"]
    quantity = String.to_integer(params["quantity"] || "1")

    case PurchaseOps.calculate_purchase_price(draw_id, ticket_number, quantity) do
      {:ok, price_breakdown} ->
        if price_breakdown.total_price <= balance do
          {:ok, price_breakdown}
        else
          {:error, "Insufficient balance for this purchase"}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp paginate_list(list, page, limit) when page > 0 and limit > 0 do
    offset = (page - 1) * limit
    list |> Enum.drop(offset) |> Enum.take(limit)
  end

  defp paginate_list(_list, _page, _limit), do: []

  defp format_purchase_response(purchase, price_breakdown) do
    %{
      id: purchase.id,
      user_id: purchase.user_id,
      draw_id: purchase.draw_id,
      purchase_type: purchase.purchase_type,
      ticket_number: purchase.ticket_number,
      fraction_number: purchase.fraction_number,
      price: price_breakdown.total_price |> Decimal.to_string(),
      purchase_date: purchase.purchase_date,
      status: purchase.status,
      price_breakdown: %{
        base_price: price_breakdown.base_price |> Decimal.to_string(),
        taxes: price_breakdown.taxes |> Decimal.to_string(),
        commissions: price_breakdown.commissions |> Decimal.to_string(),
        discounts: price_breakdown.discounts |> Decimal.to_string(),
        total: price_breakdown.total_price |> Decimal.to_string()
      }
    }
  end
end
