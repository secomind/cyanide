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
          subtype: pos_integer(),
          data: binary()
        }
end
