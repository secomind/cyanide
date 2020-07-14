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

defmodule Cyanide.EncodedValue do
  @moduledoc """
  Wraps a BSON encoded value.

  ## Fields
  * `tag` is a type integer tag (such as 0x01, 0x12, ...) as described on the BSON specification.
  * `data` is the raw encoded value iodata.
  """

  defstruct [
    :tag,
    :data
  ]

  @type t() :: %__MODULE__{
          tag: integer(),
          data: iodata()
        }
end
