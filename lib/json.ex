defmodule Json do
  # конвертира от json формат(еликсирски map) в msgpack формат

  # booleans
  def encodeValue(val) when is_nil(val), do: <<0xC0>>
  # def encodeValue("null"), do: <<0xC0>> optional
  def encodeValue(val) when is_boolean(val) and val == false, do: <<0xC2>>
  def encodeValue(val) when is_boolean(val) and val == true, do: <<0xC3>>

  # integers
  def encodeValue(val) when is_integer(val) and val >= 0 and val <= 127, do: <<0b0::1, val::7>>

  def encodeValue(val) when is_integer(val) and val >= -32 and val < 0, do: <<0b111::3, val::5>>

  def encodeValue(val) when is_integer(val) and val >= -128 and val <= 127,
    do: <<0xD0::8, val::8>>

  def encodeValue(val) when is_integer(val) and val >= -32768 and val <= 32767,
    do: <<0xD1::8, val::16>>

  def encodeValue(val) when is_integer(val) and val >= -2_147_483_648 and val <= 2_147_483_647,
    do: <<0xD2::8, val::32>>

  def encodeValue(val)
      when is_integer(val) and val >= -9_223_372_036_854_775_808 and
             val <= 9_223_372_036_854_775_807,
      do: <<0xD3::8, val::64>>

  def encodeValue(val) when is_integer(val), do: raise("int too big")
  # strings също хваща и всички binary-та :(
  def encodeValue(val) when is_bitstring(val) and byte_size(val) <= 31,
    do: <<0b101::3, byte_size(val)::5, val::binary>>

  def encodeValue(val) when is_bitstring(val) and byte_size(val) <= 255,
    do: <<0xD9::8, byte_size(val)::8, val::binary>>

  def encodeValue(val) when is_bitstring(val) and byte_size(val) <= 65535,
    do: <<0xDA::8, byte_size(val)::16, val::binary>>

  def encodeValue(val) when is_bitstring(val) and byte_size(val) <= 4_294_967_295,
    do: <<0xDB::8, byte_size(val)::32, val::binary>>

  def encodeValue(val) when is_bitstring(val), do: raise("string too big")

  # float не работи
  def encodeValue(val) when is_float(val), do: <<0xCB::8, val::64>>

  # list(array)
  def encodeValue(val) when is_list(val) and length(val) <= 15,
    do: <<0b1001::4, length(val)::4>> <> encodeListElements(val, <<>>)

  def encodeValue(val) when is_list(val) and length(val) <= 65535,
    do: <<0xDC::8, length(val)::16>> <> encodeListElements(val, <<>>)

  def encodeValue(val) when is_list(val) and length(val) <= 4_294_967_295,
    do: <<0xDD::8, length(val)::32>> <> encodeListElements(val, <<>>)

  def encodeValue(val) when is_list(val), do: raise("list too long")

  # помощни за list
  def encodeListElements([], bin), do: bin

  def encodeListElements([first | rest], bin),
    do: encodeListElements(rest, bin <> encodeValue(first))

  # map
  def encodeValue(val) when is_map(val), do: encode(val)

  # bin до тук не се стига, примерно <<1,2,3>> ще бъде хванато от #string
  def encodeValue(val) when is_binary(val) and byte_size(val) <= 255,
    do: <<0xC4::8, byte_size(val)::8, val::binary>>

  def encodeValue(val) when is_binary(val) and byte_size(val) <= 65535,
    do: <<0xC5::8, byte_size(val)::16, val::binary>>

  def encodeValue(val) when is_binary(val) and byte_size(val) <= 4_294_967_295,
    do: <<0xC6::8, byte_size(val)::32, val::binary>>

  # помощни
  def encodeSize(keys) when length(keys) <= 15, do: <<0b1000::4, length(keys)::4>>
  def encodeSize(keys) when length(keys) <= 65535, do: <<0xDE::8, length(keys)::16>>
  def encodeSize(keys), do: <<0xDF::8, length(keys)::32>>
  def encodeSize(keys), do: raise("map too big")

  def encodeValuesHelper([], values), do: values

  def encodeValuesHelper([first | rest], values),
    do: encodeValuesHelper(rest, Tuple.append(values, encodeValue(first)))

  def encodeValues(values), do: encodeValuesHelper(values, {})

  def atomToString([], strings), do: strings

  def atomToString([first | rest], strings),
    do: atomToString(rest, Tuple.append(strings, Atom.to_string(first)))

  def encodeKeysHelper([], keys), do: keys

  def encodeKeysHelper([first | rest], keys),
    do: encodeKeysHelper(rest, Tuple.append(keys, encodeValue(first)))

  def encodeKeys(keys), do: encodeKeysHelper(Tuple.to_list(atomToString(keys, {})), {})

  # json обектът се подава като map
  def encodeConstructor(size, [], [], ""), do: size
  def encodeConstructor(size, [], [], msg), do: size <> msg

  def encodeConstructor(size, [firstKey | restKeys], [firstVal | restVals], msg),
    do: encodeConstructor(size, restKeys, restVals, msg <> firstKey <> firstVal)

  def encode(json),
    do:
      encodeConstructor(
        encodeSize(Map.keys(json)),
        Tuple.to_list(encodeKeys(Map.keys(json))),
        Tuple.to_list(encodeValues(Map.values(json))),
        ""
      )
end
