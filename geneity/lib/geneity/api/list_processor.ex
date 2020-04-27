defmodule Geneity.Api.ListProcessor do
  alias Freshness.Response

  def process(result, fun) do
    with {:response, {:ok, response}} <- {:response, result},
         {:status, %Response{status: 200} = resp} <- {:status, response},
         {:parse, {:ok, list}} <- {:parse, fun.(resp.data)} do
      {:ok, list}
    else
      {:response, {:error, _} = error} -> error
      {:status, %Response{status: status}} -> {:error, status}
      {:parse, {:error, _xml_error} = error} -> error
    end
  end
end
