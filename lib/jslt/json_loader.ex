defmodule Jslt.JsonLoader do
  @moduledoc """
  Documentation for Jslt.JsonLoader.Using.
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

  defmacro load_json(file) do
    json_file = Path.join([Mix.Project.app_path, file])
    {:ok, json_text} = File.read(json_file)
    generate_json(json_text)
  end

  defp generate_json(json_text) do
    case Jason.decode(json_text) do
      {:ok, json_object} ->
        json_object = Macro.escape(json_object)
        quote do
          unquote(json_object)
        end
      _ -> :error
    end
  end
end
