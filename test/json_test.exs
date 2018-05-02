defmodule JsonTest do
  use ExUnit.Case
  doctest Json

  test "encodes empty json" do
    assert Json.encode(%{}) == <<128>>
  end

  test "encodes list as a value" do
    assert Json.encode(%{key: [1,"a",%{a: 1}]}) == <<129, 163, 107, 101, 121, 147, 1, 161, 97, 129, 161, 97, 1>>
  end

  test "encodes booleans and integers" do
    assert Json.encode(%{key1: true,key2: false,key3: 100000}) == <<131, 164, 107, 101, 121, 49, 195, 164, 107, 101, 121, 50, 194, 164, 107, 101,121, 51, 210, 0, 1, 134, 160>>
  end

  test "assert msgpack is smaller" do
    assert byte_size(Json.encode(%{something: true, number: 1234, name: "kgjfk"})) <= byte_size(inspect(%{something: true, number: 1234, name: "kgjfk"}))
  end

  test "null is nil" do
    assert Json.encode(%{key: "null"}) == Json.encode(%{key: nil})
  end
end
