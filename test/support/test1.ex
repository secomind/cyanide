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

defmodule Test1 do
  defstruct [
    :a,
    :b
  ]
end

defimpl Cyanide.Encoder, for: Test1 do
  def encode(value) do
    data =
      if value.a == value.b do
        1
      else
        0
      end

    %Cyanide.EncodedValue{
      tag: 0x08,
      data: <<data::8>>
    }
  end
end
