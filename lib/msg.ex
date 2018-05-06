defmodule Msg do
  # booleans and nil
  def decodeValue(<<0xC0>>), do: nil
  def decodeValue(<<0xC2>>), do: false
  def decodeValue(<<0xC3>>), do: true

  # integer
  def decodeValue(<<0b0::1, val::7>>), do: val
  def decodeValue(<<0b111::3, val::5>>), do: val
  def decodeValue(<<0xD0::8, val::8>>), do: val
  def decodeValue(<<0xD1::8, val::16>>), do: val
  def decodeValue(<<0xD2::8, val::32>>), do: val
  def decodeValue(<<0xD3::8, val::64>>), do: val

  # strings
  def decodeValue(<<0b101::3, size::5, val::binary>>), do: val
  def decodeValue(<<0xD9::8, size::8, val::binary>>), do: val
  def decodeValue(<<0xDA::8, size::16, val::binary>>), do: val
  def decodeValue(<<0xDB::8, size::32, val::binary>>), do: val

  # float
  def encodeValue(<<0xCB::8, val::64>>), do: val

  # list(array)

  # map

  # bin не работи
  def decodeValue(<<0xC4::8, size::8, val::binary>>), do: val
  def decodeValue(<<0xC5::8, size::16, val::binary>>), do: val
  def decodeValue(<<0xC6::8, size::32, val::binary>>), do: val
end
