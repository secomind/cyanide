#
# This file is part of Cyanide.
#
# Copyright 2020 Ispirata Srl
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

defmodule Cyanide.Binary do
  @moduledoc """
  Represents a binary with a subtype.

  ## Fields
  * `subtype` is any of `:generic`, `:function`, `:old_binary`, `:old_uuid`, `:uuid`, `:md5`,
  `:encrypted_bson`, or any user defined value (any integer >= `0x80` and <= `0xFF`).
  * `data` is a binary (such as `<<0, 1, 2>>` or `"test"`).
  """

  defstruct [
    :subtype,
    :data
  ]

  @type subtype() ::
          :generic
          | :function
          | :old_binary
          | :old_uuid
          | :uuid
          | :md5
          | :encrypted_bson
          | pos_integer()

  @type t() :: %__MODULE__{
          subtype: subtype(),
          data: binary()
        }

  @spec cast_subtype(byte) :: {:ok, subtype()} | :error
  def cast_subtype(value) when is_integer(value) and value < 0xFF do
    case value do
      0 -> {:ok, :generic}
      1 -> {:ok, :function}
      2 -> {:ok, :old_binary}
      3 -> {:ok, :old_uuid}
      4 -> {:ok, :uuid}
      5 -> {:ok, :md5}
      6 -> {:ok, :encrypted_bson}
      x when x >= 0x80 -> {:ok, x}
      _ -> :error
    end
  end

  defimpl Cyanide.Encoder do
    alias Cyanide.Binary

    def encode(%Binary{subtype: subtype, data: data}) do
      subtype_int =
        case subtype do
          :generic -> 0x00
          :function -> 0x01
          :old_binary -> 0x02
          :old_uuid -> 0x03
          :uuid -> 0x04
          :md5 -> 0x05
          :encrypted_bson -> 0x06
          ud when is_integer(ud) and ud >= 0x80 and ud <= 0xFF -> ud
        end

      {subtype_int, data}
    end
  end
end
