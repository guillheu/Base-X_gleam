import base_x_gleam/internal/encoders
import gleam/bool
import gleam/dict
import gleam/list
import gleam/string

/// Returns a tuple containing the encoding and decoding functions.
pub fn generate(
  alphabet alphabet: String,
) -> Result(#(fn(BitArray) -> String, fn(String) -> Result(BitArray, Nil)), Nil) {
  use <- bool.guard(string.length(alphabet) <= 2, Error(Nil))
  let alphabet_list = string.to_graphemes(alphabet)
  use <- bool.guard(
    alphabet_list |> list.length != alphabet_list |> list.unique |> list.length,
    Error(Nil),
  )
  let alphabet_map = encoders.alphabet_to_map(alphabet_list)
  let reverse_alphabet_map = encoders.map_reverse(alphabet_map)
  let alphabet_size = dict.size(alphabet_map)

  let encoder = encoders.encode(_, alphabet_map, alphabet_size)
  let decoder = encoders.decode(_, reverse_alphabet_map, alphabet_size)
  Ok(#(encoder, decoder))
}
