defmodule Jslt do
  @moduledoc """
  Documentation for Jslt.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Jslt.hello()
      :world

  """
  def hello do
    :world
  end

  defmacro convert_by_jslt(jslt_filename, object) do
    jslt_filename = Path.join(["priv", "jslt", jslt_filename <> ".jslt"])
    quote do
      import Jslt.JsonLoader
      Jslt.Trans.trans(Jslt.JsonLoader.load_json(unquote(jslt_filename)), unquote(object))
    end
  end
end
