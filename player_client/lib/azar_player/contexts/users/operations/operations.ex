defmodule AzarPlayerClient.Contexts.Users.Operations.Impl do
  @moduledoc """
  Implementación interna de operaciones de usuarios jugadores.

  PRIVADO: Este módulo NO debe ser usado directamente desde otros componentes.
  Siempre usar: AzarPlayer.Contexts.Users.Operations

  Contiene la lógica compleja de:
  - Validación de datos de registro
  - Hash y verificación de contraseñas
  - Persistencia de usuarios en JSON
  - Gestión de saldo y transacciones
  - Gestión de sesiones y tokens
  - Auditoría de cambios
  """

  alias AzarPlayerClient.Contexts.Users.PlayerUser
  alias AzarPlayerClient.Contexts.Users.Schemas.{Profile, Credentials, BalanceRecord}
  alias AzarShared.{Validations, CryptoHelper, JsonHelper, DateHelpers}

  @users_file "priv/data/players.json"
  @balance_file "priv/data/balance_history.json"
  @credentials_file "priv/data/credentials.json"

  # ============================================================================
  # REGISTRO Y AUTENTICACIÓN - Lógica Privada
  # ============================================================================

  @doc false
  def validate_registration_attrs(attrs) do
    with :ok <- Validations.required([:full_name, :document_number, :password], attrs),
         :ok <- validate_email_format(attrs[:email]),
         :ok <- validate_document_uniqueness(attrs[:document_number]),
         :ok <- validate_email_uniqueness(attrs[:email]),
         :ok <- validate_password_strength(attrs[:password]) do
      :ok
    else
      error -> error
    end
  end

  @doc false
  def persist_user(attrs) do
    password_hash = CryptoHelper.hash_password(attrs[:password])

    user = PlayerUser.new(Map.put(attrs, :password_hash, password_hash))

    JsonHelper.write_file(@users_file, user)
    {:ok, user}
  end

  @doc false
  def authenticate_internal(document_number, password) do
    with {:ok, user} <- find_user_by_document(document_number),
         :ok <- verify_password(password, user.password_hash),
         :ok <- check_account_active(user),
         {:ok, user} <- update_last_login(user) do
      {:ok, user}
    else
      error -> error
    end
  end

  # ============================================================================
  # GESTIÓN DE CONTRASEÑA - Lógica Privada
  # ============================================================================

  @doc false
  def validate_password_strength(password) do
    # Verificar largo mínimo
    # Verificar complejidad (mayúsculas, números, caracteres especiales)
    # Retornar :ok o {:error, reason}
  end

  defp verify_password(password, password_hash) do
    if CryptoHelper.verify_password(password, password_hash) do
      :ok
    else
      {:error, :invalid_password}
    end
  end

  @doc false
  def change_password_internal(user_id, old_password, new_password) do
    with {:ok, user} <- get_user_internal(user_id),
         :ok <- verify_password(old_password, user.password_hash),
         :ok <- validate_password_strength(new_password),
         new_hash <- CryptoHelper.hash_password(new_password),
         {:ok, updated_user} <- save_user_with_hash(user_id, new_hash) do
      {:ok, updated_user}
    else
      error -> error
    end
  end

  # ============================================================================
  # GESTIÓN DE SALDO - Lógica Privada
  # ============================================================================

  @doc false
  def credit_balance_internal(user_id, amount, reason) do
    with {:ok, user} <- get_user_internal(user_id),
         new_balance <- user.account_balance + amount,
         {:ok, _} <- update_user_balance(user_id, new_balance),
         {:ok, _} <- record_transaction(user_id, amount, :credit, reason) do
      {:ok, new_balance}
    else
      error -> error
    end
  end

  @doc false
  def debit_balance_internal(user_id, amount, reason) do
    with {:ok, user} <- get_user_internal(user_id),
         :ok <- check_sufficient_balance(user.account_balance, amount),
         new_balance <- user.account_balance - amount,
         {:ok, _} <- update_user_balance(user_id, new_balance),
         {:ok, _} <- record_transaction(user_id, amount, :debit, reason) do
      {:ok, new_balance}
    else
      error -> error
    end
  end

  # ============================================================================
  # VALIDACIONES ESPECÍFICAS - Lógica Privada
  # ============================================================================

  defp validate_email_format(email) when is_binary(email) do
    if String.match?(email, ~r/^[^\s@]+@[^\s@]+\.[^\s@]+$/) do
      :ok
    else
      {:error, "Invalid email format"}
    end
  end

  defp validate_email_format(nil), do: :ok

  defp validate_document_uniqueness(document_number) do
    # Cargar todos los usuarios del JSON
    # Verificar que no existe uno con ese documento
    # Retornar :ok o {:error, "Document already registered"}
  end

  defp validate_email_uniqueness(email) when is_binary(email) do
    # Cargar todos los usuarios del JSON
    # Verificar que no existe uno con ese email
    # Retornar :ok o {:error, "Email already registered"}
  end

  defp validate_email_uniqueness(nil), do: :ok

  defp check_account_active(user) do
    if user.status == "active" do
      :ok
    else
      {:error, :account_suspended}
    end
  end

  defp check_sufficient_balance(current_balance, amount) do
    if current_balance >= amount do
      :ok
    else
      {:error, :insufficient_funds}
    end
  end

  # ============================================================================
  # GESTIÓN DE ESTADO - Lógica Privada
  # ============================================================================

  defp update_last_login(user) do
    updated_user = %{user | last_login: DateTime.utc_now()}
    JsonHelper.write_file(@users_file, updated_user)
    {:ok, updated_user}
  end

  defp update_user_balance(user_id, new_balance) do
    with {:ok, user} <- get_user_internal(user_id) do
      updated_user = %{user | account_balance: new_balance}
      JsonHelper.write_file(@users_file, updated_user)
      {:ok, updated_user}
    end
  end

  defp save_user_with_hash(user_id, password_hash) do
    with {:ok, user} <- get_user_internal(user_id) do
      updated_user = %{user | password_hash: password_hash}
      JsonHelper.write_file(@users_file, updated_user)
      {:ok, updated_user}
    end
  end

  defp record_transaction(user_id, amount, type, reason) do
    record = BalanceRecord.new(%{
      user_id: user_id,
      amount: amount,
      transaction_type: type,
      description: reason
    })

    JsonHelper.write_file(@balance_file, record)
    {:ok, record}
  end

  # ============================================================================
  # CONSULTAS INTERNAS - Lógica Privada
  # ============================================================================

  defp get_user_internal(user_id) do
    # Cargar del JSON
    # Retornar {:ok, user} o {:error, :not_found}
  end

  defp find_user_by_document(document_number) do
    # Cargar todos del JSON
    # Filtrar por documento
    # Retornar {:ok, user} o {:error, :not_found}
  end
end
