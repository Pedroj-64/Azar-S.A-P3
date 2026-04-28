defmodule AzarServer.Views.Components do
  @moduledoc """
  Componentes reutilizables para vistas HTML.

  Proporciona funciones helper para renderizar
  elementos comunes en las templates.
  """

  import Phoenix.Component

  attr :status, :string, required: true
  attr :message, :string, required: true

  def alert(assigns) do
    ~H"""
    <div class={"alert alert-#{@status}"}>
      <%= @message %>
    </div>
    """
  end

  attr :value, :string, required: true
  attr :label, :string, required: true

  def stat_box(assigns) do
    ~H"""
    <div class="stat-box">
      <div class="stat-value"><%= @value %></div>
      <div class="stat-label"><%= @label %></div>
    </div>
    """
  end

  attr :label, :string, required: true
  attr :name, :string, required: true
  attr :type, :string, default: "text"
  attr :value, :string, default: ""
  attr :required, :boolean, default: false
  attr :placeholder, :string, default: ""

  def form_input(assigns) do
    ~H"""
    <div class="form-group">
      <label class="form-label"><%= @label %></label>
      <input 
        type={@type}
        class="form-input"
        name={@name}
        value={@value}
        placeholder={@placeholder}
        required={@required}
      />
    </div>
    """
  end

  attr :label, :string, required: true
  attr :name, :string, required: true
  attr :value, :string, default: ""
  attr :required, :boolean, default: false
  attr :rows, :integer, default: 3

  def form_textarea(assigns) do
    ~H"""
    <div class="form-group">
      <label class="form-label"><%= @label %></label>
      <textarea 
        class="form-textarea"
        name={@name}
        rows={@rows}
        required={@required}
      ><%= @value %></textarea>
    </div>
    """
  end

  attr :label, :string, required: true
  attr :name, :string, required: true
  attr :options, :list, required: true
  attr :value, :string, default: ""
  attr :required, :boolean, default: false

  def form_select(assigns) do
    ~H"""
    <div class="form-group">
      <label class="form-label"><%= @label %></label>
      <select class="form-select" name={@name} required={@required}>
        <%= for {label, value} <- @options do %>
          <option value={value} selected={@value == value}><%= label %></option>
        <% end %>
      </select>
    </div>
    """
  end

  attr :text, :string, required: true
  attr :type, :string, default: "primary"
  attr :href, :string, default: "#"
  attr :disabled, :boolean, default: false

  def button(assigns) do
    ~H"""
    <a href={@href} class={"btn btn-#{@type}"} disabled={@disabled}>
      <%= @text %>
    </a>
    """
  end

  attr :badge_type, :string, required: true
  attr :text, :string, required: true

  def badge(assigns) do
    ~H"""
    <span class={"badge badge-#{@badge_type}"}>
      <%= @text %>
    </span>
    """
  end

  attr :rows, :list, required: true
  attr :columns, :list, required: true

  def table(assigns) do
    ~H"""
    <div style="overflow-x: auto;">
      <table class="table">
        <thead>
          <tr>
            <%= for column <- @columns do %>
              <th><%= column.label %></th>
            <% end %>
          </tr>
        </thead>
        <tbody>
          <%= for row <- @rows do %>
            <tr>
              <%= for column <- @columns do %>
                <td><%= Map.get(row, column.key) %></td>
              <% end %>
            </tr>
          <% end %>
        </tbody>
      </table>
    </div>
    """
  end
end
