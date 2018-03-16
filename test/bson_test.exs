Code.require_file "test_helper.exs", __DIR__

defmodule Bson.Test do
  use ExUnit.Case

  doctest Bson
  doctest Bson.ObjectId
  doctest Bson.UTC
  doctest Bson.Decoder
  doctest Cyanide.Encoder.Float
  doctest Cyanide.Encoder.Integer
  doctest Cyanide.Encoder.Atom
  doctest Cyanide.Encoder.Bson.Regex
  doctest Cyanide.Encoder.Bson.ObjectId
  doctest Cyanide.Encoder.Bson.JS
  doctest Cyanide.Encoder.Bson.Bin
  doctest Cyanide.Encoder.Bson.Timestamp
  doctest Cyanide.Encoder.BitString
  doctest Cyanide.Encoder.Bson.UTC
  doctest Cyanide.Encoder.List
  doctest Cyanide.Encoder.Map

end
