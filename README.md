# base_x_gleam
Base-X encoding and decoding implementation in Gleam!

Allows the creation of encoders and decoders for arbitrary character sets (alphabets).

Can be used for encoding and decoding hexadecimal and base-64, but is mostly most useful for more archaic alphabets (like base58 used in some blockchain applications).

Currently only supports the Erlang target.

Also see [the Elixir `BaseX` library](https://hexdocs.pm/basex/BaseX.html) and [the Javascript `base-x` npm package](https://www.npmjs.com/package/base-x)

[![Package Version](https://img.shields.io/hexpm/v/base_x_gleam)](https://hex.pm/packages/base_x_gleam)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/base_x_gleam/)

```sh
gleam add base_x_gleam
```
```gleam
import base_x_gleam
import gleam/bit_array

pub fn main() {
  // base58 alphabet
  let b58_alphabet = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
  // Will return an error if the alphabet contains duplicates
  let assert Ok(b58_encoder, b58_decoder) = base_x_gleam.generate(alphabet)
  "foobar"
  |> bit_array.from_string
  |> b58_encoder    // "t1Zv2yaZ"

  "3FhSYN5Ra1ZtmGfAC"
  |> b58_decoder    // Ok(<<"wibblewobble">>)
}
```

Further documentation can be found at <https://hexdocs.pm/base_x_gleam>.