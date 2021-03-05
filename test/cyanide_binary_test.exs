#
# This file is part of Cyanide.
#
# Copyright 2021 Ispirata Srl
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

defmodule CyanideBinaryTest do
  use ExUnit.Case
  alias Cyanide.Binary

  test "decode a valid 0x00 subtype" do
    assert {:ok, _} = Binary.cast_subtype(0)
  end

  test "decode a subtype > 0x80 to itself" do
    assert {:ok, 128} = Binary.cast_subtype(128)
  end

  test "error on decoding a 0x06 < subtype < 0x80" do
    assert :error = Binary.cast_subtype(7)
  end

  test "fail on decoding a non-8-bit binary" do
    assert catch_error(Binary.cast_subtype(256))
  end
end
