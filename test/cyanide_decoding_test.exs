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

defmodule CyanideDecodingTest do
  use ExUnit.Case

  test "decode an empty document" do
    empty_doc = <<5, 0, 0, 0, 0>>
    assert Cyanide.decode(empty_doc) == {:ok, %{}}
  end

  test "decode a single int32 value map to bson" do
    bson_doc =
      <<0x14, 0x00, 0x00, 0x00, 0x12, "int64", 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00,
        0x00, 0x00>>

    assert Cyanide.decode(bson_doc) == {:ok, %{"int64" => 2_147_483_648}}

    short_key_bson_doc = <<16, 0, 0, 0, 18, 118, 0, 0, 0, 0, 128, 0, 0, 0, 0, 0>>
    assert Cyanide.decode(short_key_bson_doc) == {:ok, %{"v" => 2_147_483_648}}
  end

  test "decode a single int64 value map to bson" do
    bson_doc =
      <<0x14, 0x00, 0x00, 0x00, 0x12, "int64", 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00,
        0x00, 0x00>>

    # MAX_INT32 + 1 that is an int64 with "int64" key
    assert Cyanide.decode(bson_doc) == {:ok, %{"int64" => 2_147_483_648}}

    # MAX_INT32 + 1 that is an int64 with "v" key
    short_key_bson_doc = <<16, 0, 0, 0, 18, 118, 0, 0, 0, 0, 128, 0, 0, 0, 0, 0>>
    assert Cyanide.decode(short_key_bson_doc) == {:ok, %{"v" => 2_147_483_648}}

    # MAX_INT32 - 1 that is a int64
    negative_bson_doc =
      <<20, 0, 0, 0, 18, 105, 110, 116, 54, 52, 0, 255, 255, 255, 127, 255, 255, 255, 255, 0>>

    assert Cyanide.decode(negative_bson_doc) == {:ok, %{"int64" => -2_147_483_649}}
  end

  test "error on invalid empty bson" do
    assert Cyanide.decode(<<>>) == {:error, :invalid_bson}
  end

  test "decode a single double value map to bson" do
    double_bson_doc =
      <<19, 0, 0, 0, 1, 114, 101, 97, 108, 0, 154, 153, 153, 153, 153, 153, 241, 191, 0>>

    assert Cyanide.decode(double_bson_doc) == {:ok, %{"real" => -1.1}}

    double_bson_doc_1 = <<16, 0, 0, 0, 1, 118, 0, 1, 0, 0, 0, 0, 0, 240, 63, 0>>

    assert Cyanide.decode(double_bson_doc_1) == {:ok, %{"v" => 1.0000000000000002}}
  end

  test "decode special floating point values" do
    nan_bson_doc =
      <<0x17, 0x00, 0x00, 0x00, 0x01, "not_real", 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xF8,
        0x7F, 0x00>>

    assert Cyanide.decode(nan_bson_doc) == {:ok, %{"not_real" => :NaN}}

    nan2_bson_doc =
      <<0x17, 0x00, 0x00, 0x00, 0x01, "not_real", 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xF8,
        0xFF, 0x00>>

    assert Cyanide.decode(nan2_bson_doc) == {:ok, %{"not_real" => :NaN}}

    inf_bson_doc =
      <<0x17, 0x00, 0x00, 0x00, 0x01, "not_real", 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xF0,
        0x7F, 0x00>>

    assert Cyanide.decode(inf_bson_doc) == {:ok, %{"not_real" => :inf}}

    minus_inf_bson_doc =
      <<0x18, 0x00, 0x00, 0x00, 0x01, "minus_inf", 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xF0,
        0xFF, 0x00>>

    assert Cyanide.decode(minus_inf_bson_doc) == {:ok, %{"minus_inf" => :"-inf"}}
  end

  test "decode string values" do
    emptry_string_bson_doc = <<13, 0, 0, 0, 2, 118, 0, 1, 0, 0, 0, 0, 0>>

    assert Cyanide.decode(emptry_string_bson_doc) == {:ok, %{"v" => ""}}

    ascii_string_bson_doc =
      <<35, 0, 0, 0, 2, 115, 116, 114, 105, 110, 103, 0, 18, 0, 0, 0, 115, 111, 109, 101, 95, 97,
        115, 99, 105, 105, 95, 115, 116, 114, 105, 110, 103, 0, 0>>

    assert Cyanide.decode(ascii_string_bson_doc) == {:ok, %{"string" => "some_ascii_string"}}

    utf8_string_bson_doc =
      <<32, 0, 0, 0, 2, 117, 116, 102, 45, 56, 0, 16, 0, 0, 0, 227, 131, 166, 227, 131, 139, 227,
        130, 179, 227, 131, 188, 227, 131, 137, 0, 0>>

    assert Cyanide.decode(utf8_string_bson_doc) == {:ok, %{"utf-8" => "ユニコード"}}
  end

  test "decode boolean values" do
    bool_true_bson_doc = <<12, 0, 0, 0, 8, 98, 111, 111, 108, 0, 1, 0>>

    assert Cyanide.decode(bool_true_bson_doc) == {:ok, %{"bool" => true}}

    bool_false_bson_doc = <<12, 0, 0, 0, 8, 98, 111, 111, 108, 0, 0, 0>>

    assert Cyanide.decode(bool_false_bson_doc) == {:ok, %{"bool" => false}}
  end

  test "decode date time value" do
    datetime_bson_doc = <<16, 0, 0, 0, 9, 118, 0, 46, 53, 138, 231, 104, 1, 0, 0, 0>>

    {:ok, expected_datetime, 0} = DateTime.from_iso8601("2019-02-13T15:47:01.038Z")
    assert Cyanide.decode(datetime_bson_doc) == {:ok, %{"v" => expected_datetime}}

    datetime1950_bson_doc = <<16, 0, 0, 0, 9, 118, 0, 46, 61, 61, 237, 109, 255, 255, 255, 0>>

    {:ok, expected_1950datetime, 0} = DateTime.from_iso8601("1950-02-13T15:47:01.038Z")
    assert Cyanide.decode(datetime1950_bson_doc) == {:ok, %{"v" => expected_1950datetime}}
  end

  test "decode a single map value map to bson" do
    empty_map = <<13, 0, 0, 0, 3, 118, 0, 5, 0, 0, 0, 0, 0>>

    assert Cyanide.decode(empty_map) == {:ok, %{"v" => %{}}}

    nested_nested_map_bson = <<21, 0, 0, 0, 3, 97, 0, 13, 0, 0, 0, 3, 98, 0, 5, 0, 0, 0, 0, 0, 0>>

    assert Cyanide.decode(nested_nested_map_bson) == {:ok, %{"a" => %{"b" => %{}}}}

    nested_map = <<20, 0, 0, 0, 3, 118, 0, 12, 0, 0, 0, 16, 118, 0, 5, 0, 0, 0, 0, 0>>

    assert Cyanide.decode(nested_map) == {:ok, %{"v" => %{"v" => 5}}}

    nested_map_with_string =
      <<33, 0, 0, 0, 3, 118, 0, 25, 0, 0, 0, 2, 97, 95, 115, 116, 114, 105, 110, 103, 0, 6, 0, 0,
        0, 104, 101, 108, 108, 111, 0, 0, 0>>

    assert Cyanide.decode(nested_map_with_string) == {:ok, %{"v" => %{"a_string" => "hello"}}}
  end

  test "decode a single list value map to bson" do
    empty_list_bson_doc = <<18, 0, 0, 0, 4, 109, 121, 108, 105, 115, 116, 0, 5, 0, 0, 0, 0, 0>>

    assert Cyanide.decode(empty_list_bson_doc) == {:ok, %{"mylist" => []}}

    single_item_list_bson_doc =
      <<25, 0, 0, 0, 4, 109, 121, 108, 105, 115, 116, 0, 12, 0, 0, 0, 16, 48, 0, 1, 0, 0, 0, 0,
        0>>

    assert Cyanide.decode(single_item_list_bson_doc) == {:ok, %{"mylist" => [1]}}

    two_item_list_bson_doc =
      <<32, 0, 0, 0, 4, 109, 121, 108, 105, 115, 116, 0, 19, 0, 0, 0, 16, 48, 0, 1, 0, 0, 0, 16,
        49, 0, 2, 0, 0, 0, 0, 0>>

    assert Cyanide.decode(two_item_list_bson_doc) == {:ok, %{"mylist" => [1, 2]}}

    three_mixed_item_list_bson_doc =
      <<44, 0, 0, 0, 4, 118, 0, 36, 0, 0, 0, 16, 48, 0, 1, 0, 0, 0, 2, 49, 0, 6, 0, 0, 0, 119,
        111, 114, 108, 100, 0, 1, 50, 0, 102, 102, 102, 102, 102, 102, 254, 63, 0, 0>>

    assert Cyanide.decode(three_mixed_item_list_bson_doc) == {:ok, %{"v" => [1, "world", 1.9]}}
  end

  test "decode a single binary value map to bson" do
    binary_bson_doc = <<20, 0, 0, 0, 5, 98, 105, 110, 0, 5, 0, 0, 0, 0, 0, 1, 0, 2, 0, 0>>

    assert Cyanide.decode(binary_bson_doc) == {:ok, %{"bin" => {0, <<0, 1, 0, 2, 0>>}}}
  end

  test "decode nil value" do
    nil_bson_doc = <<12, 0, 0, 0, 10, 118, 97, 108, 117, 101, 0, 0>>

    assert Cyanide.decode(nil_bson_doc) == {:ok, %{"value" => nil}}
  end

  test "error on invalid header only bson" do
    assert Cyanide.decode(<<1>>) == {:error, :invalid_bson}
    assert Cyanide.decode(<<2, 0>>) == {:error, :invalid_bson}
    assert Cyanide.decode(<<3, 0, 0>>) == {:error, :invalid_bson}
    assert Cyanide.decode(<<4, 0, 0, 0>>) == {:error, :invalid_bson}
  end
end
