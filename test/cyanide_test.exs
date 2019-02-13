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

defmodule CyanideTest do
  use ExUnit.Case

  test "encodes and decodes a map" do
    map1 = %{
      "t" => DateTime.utc_now |> DateTime.to_unix(:millisecond),
      "v" => %{
        "some_binary" => {0, <<0, 0, 0, 0>>},
        "array" => [1, 2, 3, 4, 5],
        "some_bool" => true,
        "a_string" => "This is a string",
        "int_value0" => 1,
        "int_value1" => -1,
        "int_value2" => 1_152_921_504_606_846_976,
        "int_value3" => -1_152_921_504_606_846_976
      }
    }

    assert Cyanide.decode!(Cyanide.encode!(map1)) == map1
  end

  test "encodes and decodes a complex map" do
    map2 = %{
      "t" => DateTime.utc_now |> DateTime.to_unix(:millisecond),
      "bin1" => {0, <<0, 1, 2, 3>>},
      "bin2" => {0, <<0>>},
      "bin3" => {0, <<>>},
      "map1" => %{},
      "map2" => %{"a" => true, "b" => false, "c" => nil},
      "map3" => %{
        "v" => [
          0,
          -1,
          1,
          2_147_483_647,
          2_147_483_648,
          -2_147_483_648,
          -2_147_483_649,
          9_223_372_036_854_775_807,
          -9_223_372_036_854_775_808
        ],
        "map4" => %{
          "map5" => %{
            "map6" => %{
              "v" => []
            }
          }
        }
      }
    }

    assert Cyanide.decode!(Cyanide.encode!(map2)) == map2
  end

  test "encodes and decodes a map made of special float values" do
    map3 = %{
      "v1" => :NaN,
      "v2" => :"-inf",
      "v3" => :inf
    }

    assert Cyanide.decode!(Cyanide.encode!(map3)) == map3
  end

  test "encodes and decodes a map made of floating point values" do
    map4 = %{
      "0" => 0,
      "a" => 1.1,
      "b" => 1.2,
      "c" => 1.3,
      "d" => 2,
      "e" => %{
        "some_value" => 5.2,
        "NaN" => :NaN,
        "inf" => :inf,
        "-inf" => :"-inf"
      },
      "f" => %{
        "some_value" => 6
      }
    }

    assert Cyanide.decode!(Cyanide.encode!(map4)) == map4
  end

  test "encodes and decodes an array of special float values" do
    map5 = %{
      "v" => [:NaN, :"-inf", :inf, :NaN]
    }

    assert Cyanide.decode!(Cyanide.encode!(map5)) == map5
  end

  test "encoding and decoding of an ascending ordered array" do
    o1 = %{
      "v" => [0, 1, 2, 3, 4]
    }

    assert Cyanide.decode!(Cyanide.encode!(o1)) == o1
  end

  test "encoding and decoding of a descending ordered array" do
    o2 = %{
      "v" => [5, 4, 3, 2, 1, 0]
    }

    assert Cyanide.decode!(Cyanide.encode!(o2)) == o2
  end

  test "encoding and decoding of an unordered array" do
    o3 = %{
      "v" => [0, 4, 3, 7, 1, 0]
    }

    assert Cyanide.decode!(Cyanide.encode!(o3)) == o3
  end
end
