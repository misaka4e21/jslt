defmodule JsltTransTest do
  use ExUnit.Case
  doctest Jslt.Trans

  test "translates simple constants" do
    assert Jslt.Trans.trans("$const:233", "250") == "233"
    assert Jslt.Trans.trans("233", "250") == "233"
    assert Jslt.Trans.trans(233, 250) == 233
    assert Jslt.Trans.trans(true, false) == true
    assert Jslt.Trans.trans(nil, "El pueblo unido") == nil
    assert Jslt.Trans.trans("The people united", nil) == "The people united"
  end

  test "translates simple objects" do
    assert Jslt.Trans.trans("$const:String", %{"string" => "str"}) == "String"
    assert Jslt.Trans.trans(%{"string" => "str"}, "$const:String") == %{"string" => "str"}
    assert Jslt.Trans.trans(%{"string" => "$const:str"}, "$const:String") == %{"string" => "str"}
  end
end
