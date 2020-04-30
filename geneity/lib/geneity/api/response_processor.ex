defmodule Geneity.Api.ResponseProcessor do
  alias Freshness.Response

  def process(result, fun) do
    with {:response, {:ok, response}} <- {:response, result},
         {:status, %Response{status: 200} = resp} <- {:status, response},
         {:parse, {:ok, response}} <- {:parse, fun.(resp.data)} do
      {:ok, response}
    else
      {:response, {:error, _} = error} -> error
      {:status, %Response{status: status}} -> {:error, status}
      {:parse, {:error, _xml_error} = error} -> error
    end
  end
end
