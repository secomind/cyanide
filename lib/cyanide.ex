#
# This file is part of Cyanide.
#
# Copyright 2019 Ispirata Srl
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

defmodule Cyanide do
  @type bson_type ::
          float()
          | String.t()
          | bson_map()
          | list(bson_type())
          | {integer(), binary()}
          | boolean()
          | nil
          | integer()
          | DateTime.t()
  @type bson_map :: %{optional(String.t()) => bson_type()}

  @spec decode(binary()) :: {:ok, bson_map()} | {:error, :invalid_bson}
  def decode(document) do
    with <<doc_size::little-32, rest::binary>> when doc_size == byte_size(rest) + 4 <- document,
         values_map when is_map(values_map) <- parse_doc_bytes(%{}, rest) do
      {:ok, values_map}
    else
      wrong_size when is_integer(wrong_size) ->
        {:error, :invalid_bson}

      short_document when is_binary(short_document) ->
        {:error, :invalid_bson}

      {:error, :invalid_bson} ->
        {:error, :invalid_bson}
    end
  end

  @spec decode!(binary) :: bson_map
  def decode!(document) do
    {:ok, document_map} = decode(document)
    document_map
  end

  defp parse_doc_bytes(map, <<0>>) do
    map
  end

  defp parse_doc_bytes(map, key_value_binary) do
    with splitted = split_cstring(key_value_binary),
         {<<type::8, key::binary>>, rest} <- splitted,
         true <- String.valid?(key) do
      parse_value(type, map, key, rest)
    else
      _any ->
        {:error, :invalid_bson}
    end
  end

  defp parse_value(0x1, map, key, <<0::48, 240, 127, rest::binary>>) do
    Map.put(map, key, :inf)
    |> parse_doc_bytes(rest)
  end

  defp parse_value(0x1, map, key, <<0::48, 240, 255, rest::binary>>) do
    Map.put(map, key, :"-inf")
    |> parse_doc_bytes(rest)
  end

  defp parse_value(0x1, map, key, <<0::48, 248, 127, rest::binary>>) do
    Map.put(map, key, :NaN)
    |> parse_doc_bytes(rest)
  end

  defp parse_value(0x1, map, key, <<0::48, 248, 255, rest::binary>>) do
    Map.put(map, key, :NaN)
    |> parse_doc_bytes(rest)
  end

  defp parse_value(0x1, map, key, <<value::little-float-64, rest::binary>>) do
    Map.put(map, key, value)
    |> parse_doc_bytes(rest)
  end

  defp parse_value(0x2, map, key, <<string_size::little-32, string_and_rest::binary>>) do
    with no_zero_size when no_zero_size >= 0 <- string_size - 1,
         <<value::binary-size(no_zero_size), 0::8, rest::binary>> <- string_and_rest do
      Map.put(map, key, value)
      |> parse_doc_bytes(rest)
    else
      _any ->
        {:error, :invalid_bson}
    end
  end

  defp parse_value(0x3, map, key, <<subdoc_size::little-32, subdoc_and_rest::binary>>) do
    with the_size when the_size >= 1 <- subdoc_size - 4,
         <<subdocument::binary-size(the_size), rest::binary>> <- subdoc_and_rest do
      Map.put(map, key, parse_doc_bytes(%{}, subdocument))
      |> parse_doc_bytes(rest)
    else
      _any ->
        {:error, :invalid_bson}
    end
  end

  defp parse_value(0x4, map, key, <<5, 0, 0, 0, 0, rest::binary>>) do
    Map.put(map, key, [])
    |> parse_doc_bytes(rest)
  end

  defp parse_value(0x4, map, key, <<subdoc_size::little-32, subdoc_and_rest::binary>>) do
    with the_size when the_size >= 1 <- subdoc_size - 4,
         <<subdocument::binary-size(the_size), rest::binary>> <- subdoc_and_rest do
      array_subdoc = parse_doc_bytes(%{}, subdocument)
      array_max_index = map_size(array_subdoc) - 1

      map_array_to_list = fn index, acc ->
        with index_string = to_string(index),
             {:ok, value} <- Map.fetch(array_subdoc, index_string) do
          {:cont, [value | acc]}
        else
          :error ->
            {:halt, {:error, :invalid_bson}}
        end
      end

      with values_list when is_list(values_list) <-
             Enum.reduce_while(array_max_index..0, [], map_array_to_list) do
        Map.put(map, key, values_list)
        |> parse_doc_bytes(rest)
      end
    else
      _any ->
        {:error, :invalid_bson}
    end
  end

  defp parse_value(0x5, map, key, <<subdoc_size::little-32, subtype::8, subdoc_and_rest::binary>>) do
    with the_size when the_size >= 0 <- subdoc_size,
         <<subdocument::binary-size(the_size), rest::binary>> <- subdoc_and_rest do
      Map.put(map, key, {subtype, subdocument})
      |> parse_doc_bytes(rest)
    else
      _any ->
        {:error, :invalid_bson}
    end
  end

  defp parse_value(0x8, map, key, <<0::8, rest::binary>>) do
    Map.put(map, key, false)
    |> parse_doc_bytes(rest)
  end

  defp parse_value(0x8, map, key, <<1::8, rest::binary>>) do
    Map.put(map, key, true)
    |> parse_doc_bytes(rest)
  end

  defp parse_value(0x9, map, key, <<value::signed-little-64, rest::binary>>) do
    with {:ok, datetime} <- DateTime.from_unix(value, :millisecond) do
      Map.put(map, key, datetime)
      |> parse_doc_bytes(rest)
    else
      _any ->
        {:error, :invalid_bson}
    end
  end

  defp parse_value(0xA, map, key, rest) do
    Map.put(map, key, nil)
    |> parse_doc_bytes(rest)
  end

  defp parse_value(0x10, map, key, <<value::signed-little-32, rest::binary>>) do
    Map.put(map, key, value)
    |> parse_doc_bytes(rest)
  end

  defp parse_value(0x12, map, key, <<value::signed-little-64, rest::binary>>) do
    Map.put(map, key, value)
    |> parse_doc_bytes(rest)
  end

  defp parse_value(_type, _map, _key, _invalid_bson) do
    {:error, :invalid_bson}
  end

  defp split_cstring(blob) do
    split_cstring(blob, 1, byte_size(blob) - 1)
  end

  defp split_cstring(blob, n, max_len) when n < max_len do
    case blob do
      <<cstring::binary-size(n), 0::8, rest::binary>> ->
        {cstring, rest}

      _ ->
        split_cstring(blob, n + 1, max_len)
    end
  end

  defp split_cstring(_blob, _n, _max_len) do
    :error
  end

  @spec encode(bson_map()) :: {:ok, binary()}
  def encode(document) do
    with {:ok, doc_iolist} <- document_to_iolist(document) do
      {:ok, :erlang.iolist_to_binary(doc_iolist)}
    else
      :error ->
        {:error, :cannot_bson_encode}
    end
  end

  @spec encode!(bson_map()) :: binary()
  def encode!(document) do
    {:ok, document_binary} = encode(document)
    document_binary
  end

  defp document_to_iolist(document) do
    values_io_list =
      Enum.map(document, fn {key, value} ->
        to_string(key)
        |> encode_value(value)
      end)

    with document_iolist when is_list(document_iolist) <- finalize_document(values_io_list) do
      {:ok, document_iolist}
    end
  end

  defp finalize_document(document) do
    if Enum.any?(document, fn item -> item == :error end) do
      :error
    else
      doc_size = :erlang.iolist_size(document) + 5
      [<<doc_size::signed-little-32>>, document, <<0>>]
    end
  end

  defp encode_value(key_string, value) when is_float(value) do
    [<<0x1>>, key_string, <<0>> | <<value::little-float-64>>]
  end

  defp encode_value(key_string, :NaN) do
    [<<0x1>>, key_string, <<0, 0::48, 248, 127>>]
  end

  defp encode_value(key_string, :inf) do
    [<<0x1>>, key_string, <<0, 0::48, 240, 127>>]
  end

  defp encode_value(key_string, :"-inf") do
    [<<0x1>>, key_string, <<0, 0::48, 240, 255>>]
  end

  defp encode_value(key_string, value) when is_binary(value) do
    string_size = byte_size(value) + 1

    [<<0x2>>, key_string, <<0, string_size::signed-little-32>>, value | <<0>>]
  end

  defp encode_value(key_string, %DateTime{} = value) do
    timestamp_ms = DateTime.to_unix(value, :millisecond)
    [<<0x9>>, key_string, <<0>> | <<timestamp_ms::signed-little-64>>]
  end

  defp encode_value(key_string, value) when is_map(value) do
    with {:ok, doc_iolist} <- document_to_iolist(value) do
      [<<0x3>>, key_string, <<0>> | doc_iolist]
    end
  end

  defp encode_value(key_string, value) when is_list(value) do
    with the_list when is_list(the_list) <- reverse_encode_list(value, 0, []) do
      [<<0x4>>, key_string, <<0>> | the_list]
    end
  end

  defp encode_value(key_string, {subtype, value})
       when is_integer(subtype) and subtype >= 0 and subtype <= 255 and is_binary(value) do
    binary_size = byte_size(value)

    [<<0x5>>, key_string, <<0, binary_size::signed-little-32, subtype::8>>, value]
  end

  defp encode_value(key_string, false) do
    [<<0x8>>, key_string | <<0, 0>>]
  end

  defp encode_value(key_string, true) do
    [<<0x8>>, key_string | <<0, 1>>]
  end

  defp encode_value(key_string, nil) do
    [<<0xA>>, key_string | <<0>>]
  end

  defp encode_value(key_string, value)
       when is_integer(value) and value >= -2_147_483_648 and value <= 2_147_483_647 do
    [<<0x10>>, key_string, <<0>> | <<value::signed-little-32>>]
  end

  defp encode_value(key_string, value)
       when is_integer(value) and value >= -9_223_372_036_854_775_808 and
              value <= 9_223_372_036_854_775_807 do
    [<<0x12>>, key_string, <<0>> | <<value::signed-little-64>>]
  end

  defp encode_value(_key_string, _value) do
    :error
  end

  defp reverse_encode_list(_list, _index, [:error | _t]) do
    :error
  end

  defp reverse_encode_list([], _index, acc_list) do
    reversed_list = :lists.reverse(acc_list)
    finalize_document(reversed_list)
  end

  defp reverse_encode_list([head_value | tail], index, acc_list) do
    reverse_encode_list(tail, index + 1, [
      encode_value(Integer.to_string(index), head_value) | acc_list
    ])
  end
end
