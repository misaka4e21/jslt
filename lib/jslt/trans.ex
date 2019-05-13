defmodule Jslt.Trans do

  defp keylist_from_dotstring(dotstr) do
    String.split(dotstr, ".")
  end

  defp parse_val("...") do
    {:rest}
  end
  defp parse_val("ref:" <> key) do
    {:reference, keylist_from_dotstring(key)}
  end
  defp parse_val("const:" <> string) do
    {:const, string}
  end
  defp parse_val(map = %{}) do
    {:object, map}
  end
  defp parse_val(other) do
    {:const, other}
  end

  defp resolve([head|tail], obj) do
    resolve(tail, Map.get(obj, head))
  end
  defp resolve([], obj) do
    obj
  end

  defp apply_parse_val(jslt, acc, obj, key, val) do
    val = parse_val(val)
    case val do
      {:rest} ->
          Map.merge(acc, obj)
      {:const, val} ->
          Map.put(acc, key, val)
      {:object, _} ->
          Map.put(acc, key,
                  eval_parse_val(Map.get(jslt, key),
                                 Map.get(obj, key)))
      {:reference, keylist} ->
          Map.put(acc, key, resolve(keylist, obj))
    end
  end

  defp eval_parse_val(jslt, obj) do
    jslt
    |> Enum.reduce(%{}, fn {key, value}, acc ->
      apply_parse_val(jslt, acc, obj, key, value)
    end)
  end

  def trans(jslt, obj) do
    try do
      eval_parse_val(jslt, obj)
    rescue
      _ ->
        :error
    end
  end
end
