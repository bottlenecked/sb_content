defmodule Geneity.Api do
  defmodule Behaviour do
    alias Geneity.Api.Operator
    alias Model.Event

    @callback get_event_data(pos_integer(), Operator.t(), String.t()) ::
                {:ok, Event.t()} | {:error, any()}

    @callback get_sport_ids(Operator.t()) :: {:ok, list(String.t())} | {:error, any()}

    @callback get_league_ids_for_sport(String.t(), Operator.t()) ::
                {:ok, list(non_neg_integer())} | {:error, any()}

    @callback get_event_ids_for_league(non_neg_integer(), Operator.t()) ::
                {:ok, list(non_neg_integer())} | {:error, any()}

    @callback get_live_event_ids(Operator.t()) ::
                {:ok, list(non_neg_integer())} | {:error, any()}
  end

  def get_event_data(ev_id, operator_id, language),
    do: get_implementation_module().get_event_data(ev_id, operator_id, language)

  def get_sport_ids(operator_id), do: get_implementation_module().get_sport_ids(operator_id)

  def get_league_ids_for_sport(sport_id, operator_id),
    do: get_implementation_module().get_league_ids_for_sport(sport_id, operator_id)

  def get_event_ids_for_league(league_id, operator_id),
    do: get_implementation_module().get_event_ids_for_league(league_id, operator_id)

  def get_live_event_ids(operator_id),
    do: get_implementation_module().get_live_event_ids(operator_id)

  defp get_implementation_module() do
    case Application.get_env(:geneity, :api_module) do
      nil ->
        raise "Geneity api_module needs to be explicitly set by calling Geneity.Api.set_api_mode/1 before attempting to fetch content"

      other ->
        other
    end
  end

  def set_api_mode(:prod) do
    Application.put_env(:geneity, :api_module, Geneity.Api.HttpApi)
  end

  def set_api_mode(:test) do
    Application.put_env(:geneity, :api_module, Geneity.Api.SimulationApi)
  end
end
