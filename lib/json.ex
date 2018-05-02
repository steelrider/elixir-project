defmodule Json do

  def encodeValue(val) when is_nil(val), do: <<0xc0>>
  def encodeValue("null"), do: <<0xc0>>
  def encodeValue(val) when is_boolean(val) and val==false, do: <<0xc2>>
  def encodeValue(val) when is_boolean(val) and val==true, do: <<0xc3>>
  def encodeValue(val) when is_integer(val), do: <<0b111::3,val::5>>
  def encodeValue(val) when is_bitstring(val) and byte_size(val)<=31, do: <<0b101::3,byte_size(val)::5,val::binary>>
  def encodeValue(val) when is_bitstring(val) and byte_size(val)<=255, do: <<0xD9::8,byte_size(val),val::binary>>

  def encodeSize(keys) when length(keys)<=15, do: <<0b1000::4,length(keys)::4>>
  def encodeSize(keys) when length(keys)<=65535, do: <<0xDE::8,length(keys)::16>>
  def encodeSize(keys), do: <<0xDF::8,length(keys)::32>>

  def encodeValuesHelper([],values), do: values
  def encodeValuesHelper([first|rest],values), do: encodeValuesHelper(rest,Tuple.append(values,encodeValue(first)))
  def encodeValues(values), do: encodeValuesHelper(values,{})
 
  def atomToString([],strings), do: strings
  def atomToString([first|rest],strings), do: atomToString(rest,Tuple.append(strings,Atom.to_string(first)))

  def encodeKeysHelper([],keys), do: keys
  def encodeKeysHelper([first|rest],keys) when byte_size(first)<=31, do: encodeKeysHelper(rest,Tuple.append(keys,encodeValue(first)))
  def encodeKeysHelper([first|rest],keys) when byte_size(first)<=255, do: encodeKeysHelper(rest,Tuple.append(keys,encodeValue(first)))
  def encodeKeys(keys), do: encodeKeysHelper(Tuple.to_list(atomToString(keys,{})),{})

  def encodeConstructor(size,[],[],""), do: size
  def encodeConstructor(size,[],[],msg), do: size<>msg
  def encodeConstructor(size,[firstKey|restKeys],[firstVal|restVals],msg), do: encodeConstructor(size,restKeys,restVals,msg<>firstKey<>firstVal)
  def encode(json), do: encodeConstructor(encodeSize(Map.keys(json)),Tuple.to_list(encodeKeys(Map.keys(json))),Tuple.to_list(encodeValues(Map.values(json))),"")
end
