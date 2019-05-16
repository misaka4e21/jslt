defmodule Jslt.Trans do
  # get an item from a generic collection.
  defp get_at(nil, _) do
    nil
  end
  defp get_at(collection, index) when is_map(collection) do
    Map.get(collection, index)
  end
  defp get_at(collection, index) when is_list(collection) do
    Enum.at(collection, index)
  end
  defp get_at(collection, index) when is_tuple(collection) do
    elem(collection, index)
  end

  defp get_from_global_env(%{} = global_env, key) do
    with {:ok, value} <- Map.fetch(global_env, key) do
      value
    else
      _ ->
        try do
          get_from_local_env(global_env, [:original|Tuple.to_list(key)])
        rescue
          _ ->
            throw(:ref_not_found)
        end
    end
  end

  defp get_from_local_env(local_env, [head|tail]) do
    get_from_local_env(get_at(local_env, head), tail)
  end
  defp get_from_local_env(local_env, []) do
    local_env
  end


  defp key_from_dotstring(dotstr) do
    String.split(dotstr, ".")
    |> Enum.map(fn str ->
      case str do
        "$" <> index ->
          String.to_integer(index)
        index ->
          index
      end
    end)
    |> List.to_tuple()
  end

  defp eval({key, "$const:" <> string}, _object, global_env) do
    {string, Map.put(global_env, key, string)}
  end

  defp eval({key, "$keep"}, object, global_env) when key != "$rest" do
    {object, Map.put(global_env, key, object)}
  end

  defp eval({key, "$ref:" <> dotstring}, _object, global_env) do
    result = get_from_global_env(global_env, key_from_dotstring(dotstring))
    {result, Map.put(global_env, key, result)}
  end

  defp eval({key, %{"$rest" => "$keep"} = map}, object, global_env) do
    map = map |> Enum.filter(fn {key, _val} -> key != "$rest" end) |> Map.new()
    {const_map, const_env} = eval_map({key, map}, map, global_env)
    {Map.merge(object, const_map), const_env}
  end

  defp eval({key, %{} = map}, _, global_env) do
    eval_map({key, map}, map, global_env)
  end

  defp eval({key, list}, _, global_env) when is_list(list) do
    indexed_list = list |> Enum.with_index() |> Enum.map(fn {val, index} -> {index, val} end)
    {list, global_env} = eval_collection({key, indexed_list}, list, global_env)
    list = Enum.map(list, fn {_, val} ->
      val
    end)
    {list, global_env}
  end

  defp eval({key, const_val}, _, global_env) do
    {const_val, Map.put(global_env, key, const_val)}
  end

  defp eval_collection({key, value}, object, global_env) do
    value
    |> Enum.map_reduce(global_env, fn {subkey, val}, acc ->
      newkey = Tuple.append(key, subkey)
      {subelem, sub_global_env} = eval({newkey, val}, get_at(object, subkey), acc)
      {{subkey, subelem}, Map.put(sub_global_env, key, subelem)}
    end)
  end

  defp eval_map({key, value}, object, global_env) do
    {maplist, global_env} = eval_collection({key, value}, object, global_env)
    {Map.new(maplist), global_env}
  end

  def trans(jslt, obj) do
    try do
      {result, _} = eval({{}, jslt}, obj, %{:original => obj})
      result
    rescue
      _ ->
        :error
    catch
      :ref_not_found ->
        :ref_not_found
    end
  end
end
