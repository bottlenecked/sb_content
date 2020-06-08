defmodule Geneity.Parser.TeamParser do
  @moduledoc """
  Parsing teams should be straight-forward, but it isn't. For most sports, the <Team> element is present.
  But in tennis there is the <Participant> element instead of team, and for table tennis there is neither
  Team nor Participant elements.

  Long story short, we need to choose which parsing logic to implement separately for each sport.
  This logic goes here to facilitate code reuse
  """

  alias Model.Team

  def handle_event(:start_element, {"Team", attributes}, state) do
    team =
      attributes
      |> Enum.reduce(%Team{}, fn
        {"team_id", id}, acc -> %{acc | id: id}
        _, acc -> acc
      end)

    %{teams: teams} = state
    teams = [team | teams]
    state = %{state | teams: teams}

    {:ok, state}
  end

  def handle_event(:end_element, "Teams", state) do
    %{teams: teams} = state
    teams = Enum.reverse(teams)
    state = %{state | teams: teams}
    {:ok, state}
  end

  def handle_event(_, _, state), do: {:ok, state}
end
