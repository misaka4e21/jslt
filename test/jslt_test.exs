defmodule JsltTest do
  use ExUnit.Case
  doctest Jslt

  test "greets the world" do
    assert Jslt.hello() == :world
  end

  test "translates object" do
    result = Jslt.convert_by_jslt("test1", %{
      "alerta" => "八紘一宇",
      "a" => %{
        "b" => nil
      }
    })
    assert result == %{
      "alerta" => "antifascista",
      "a" => %{
        "b" => nil
      },
      "subdomain" => nil
    }
  end

  test "fails to transltate wrong object" do
    result = Jslt.convert_by_jslt("test1", %{
      "a" => ["abc", 123]
    })
    assert result == :error
  end
end
