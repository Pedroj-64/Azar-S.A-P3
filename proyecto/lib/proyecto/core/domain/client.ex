defmodule AzarSa.Core.Domain.Client do
  @derive Jason.Encoder
  defstruct [
    :id,
    :name,
    :document,
    :password_hash,
    :credit_card,
    :notifications,
    :created_at
  ]

  # 🔹 Constructor
  def new(name, document, password, card) do
    %__MODULE__{
      id: generate_id(),
      name: name,
      document: document,
      password_hash: hash_password(password),
      credit_card: card,
      notifications: [],
      created_at: now()
    }
  end

  # 🔹 Hash SHA256
  defp hash_password(password) do
    :crypto.hash(:sha256, password)
    |> Base.encode16(case: :lower)
  end

  # 🔹 Helpers
  defp generate_id do
    "client_" <> (:crypto.strong_rand_bytes(4) |> Base.encode16())
  end

  defp now do
    DateTime.utc_now() |> DateTime.to_string()
  end
end
