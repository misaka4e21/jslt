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

  defp generate_object(json_object) do
    json_object = Macro.escape(json_object)
    quote do
      unquote(json_object)
    end
  end

  defmacro load_json(file, obj_generator \\ &generate_object/1) do
    json_file = Path.join([Mix.Project.app_path, file])
    {:ok, json_text} = File.read(json_file)
    generate_json(json_text, obj_generator)
  end

  defp generate_json(json_text, obj_generator) do
    case Jason.decode(json_text) do
      {:ok, json_object} ->
        obj_generator.(json_object)
      _ -> :error
    end
  end
end
