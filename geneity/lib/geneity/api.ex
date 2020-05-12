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

  defp get_implementation_module(),
    do:
      if(Mix.env() == :prod,
        do: Geneity.Api.HttpApi,
        else: Geneity.Api.SimulationApi
      )
end
