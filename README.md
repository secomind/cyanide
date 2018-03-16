Cyanide
=======
[![Build Status](https://travis-ci.org/ispirata/cyanide.svg?branch=master)](https://travis-ci.org/ispirata/cyanide)
[![Coverage Status](https://coveralls.io/repos/github/ispirata/cyanide/badge.svg?branch=master)](https://coveralls.io/github/ispirata/cyanide?branch=master)
[![Hex Version](https://img.shields.io/hexpm/v/cyanide.svg)](https://hex.pm/packages/cyanide)
[![Hex Downloads](https://img.shields.io/hexpm/dt/cyanide.svg)](https://hex.pm/packages/cyanide)

BSON implementation for Elixir Language (based on [elixir-bson](https://github.com/checkiz/elixir-bson), and it can be used as drop-in replacement) with support for recent Elixir versions.

Cyanide on GitHub [source repo](https://github.com/ispirata/cyanide)

BSON is a binary format in which zero or more key/value pairs are stored as a single entity, called a document. It is a data type with a standard binary representation defined at <http://www.bsonspec.org>.

This implements version 1.0 of that spec.

This implementation maps the Bson grammar with Elixir terms in the following way:

  - document: Map, HasDict, Keyword
  - int32 and int64: Integer
  - double: Float
  - string: String
  - Array: List (non-keyword)
  - binary: Bson.Bin (struct)
  - ObjectId: Bson.ObjectId (struct)
  - Boolean: true or false (Atom)
  - UTC datetime: Bson.UTC (struct)
  - Null value: nil (Atom)
  - Regular expression: Bson.Regex (struct)
  - JavaScript: Bson.JS (struct)
  - Timestamp: Bson.Timestamp (struct)
  - Min and Max key: `MIN_KEY` or `MAX_KEY` (Atom)

This is how to encode a sample Elixir Map into a Bson Document:

```elixir
bson = Bson.encode %{a: 1, b: "2", c: [1,2,3], d: %{d1: 10, d2: 11} }

```
In this case, `bson` would be a document with 4 elements (an Integer, a String, an Array and an embeded document). This document would correspond in Javascript to:
```javascript
{a: 1, b: "2", c: [1,2,3], d: {d1: 10, d2: 11} }
```

Conversly, to decode a bson document:
```elixir
%{a: 1} == Bson.decode <<12, 0, 0, 0, 16, 97, 0, 1, 0, 0, 0, 0>>
```

Special Bson element that do not have obvious corresponding type in Elixir are represented with Record, for example:

```elixir
jsbson = Bson.encode js: %Bson.JS{code:"function(a) return a+b;", scope: [b: 2]}
rebson = Bson.encode re: %Bson.Regex{pattern: "\d*", opts: "g"}
```

Some configuration can be done using fun or protocol implementation, ie, it is possible to redefine encoder end decoder of Bson.Bin to implement specific encoding. For that you can set Application envir for application `:bson`. Two options are available: `:decoder_new_doc` defaulted to `Bson.Decoder.elist_to_atom_map/1` and `:decoder_new_bin` defaulted to `&Bson.Bin.new/2`.
