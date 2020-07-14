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

defprotocol Cyanide.Encoder do
  @moduledoc """
  Protocol controlling how a value is encoded to BSON.

  An encode implementation can either return any encodable value or a Cyanide.EncodedValue struct.
  In most of the cases returning a map is enough, Cyanide.EncodedValue is meant to be used when a
  specific BSON type should be enforced.
  Only maps are supported for root document encoding.

  ## Example

  Let's assume a presence of the following struct:

      defmodule Test do
        defstruct [:value1, :value2]
      end

  It can be encoded using the following implementation:

      defimpl Cyanide.Encoder, for: Test do
        def encode(value) do
          Map.to_struct(value)
        end
      end

  Let's assume that a small value should be always encoded as Int64.
  This problem can be solved by implementing a wrapper struct.

      defmodule Int64 do
        defstruct [:value]
      end

  It can be encoded using the following implementation:

      defimpl Cyanide.Encoder, for: Int64 do
        def encode(wrapped) do
          value = wrapped.value

          %Cyanide.EncodedValue{
            tag: 0x12,
            data: <<value::signed-little-64>>
          }
        end
      end
  """

  @spec encode(term()) :: Cyanide.bson_type() | Cyanide.EncodedValue.t()
  def encode(value)
end
