import gleam/bit_array
import gleam/bool
import gleam/dict.{type Dict}
import gleam/io
import gleam/list
import gleam/result
import gleam/string

/// Returns a tuple containing the encoding and decoding functions.
pub fn generate(
  alphabet alphabet: String,
) -> Result(#(fn(BitArray) -> String, fn(String) -> Result(BitArray, Nil)), Nil) {
  let alphabet_list = string.to_graphemes(alphabet)
  use <- bool.guard(
    alphabet_list |> list.length != alphabet_list |> list.unique |> list.length,
    Error(Nil),
  )
  let alphabet_map = alphabet_to_map(alphabet_list)
  let reverse_alphabet_map = map_reverse(alphabet_map)
  let alphabet_size = dict.size(alphabet_map)

  let encoder = encode(_, alphabet_map, alphabet_size)
  let decoder = decode(_, reverse_alphabet_map, alphabet_size)
  Ok(#(encoder, decoder))
}

fn encode(
  input: BitArray,
  alphabet_map: Dict(Int, String),
  alphabet_size: Int,
) -> String {
  input
  |> do_decode_unsigned
  |> recurse_encode(alphabet_map, alphabet_size, "")
}

fn recurse_encode(
  remaining_input: Int,
  alphabet_map: Dict(Int, String),
  alphabet_length: Int,
  acc: String,
) -> String {
  let remainder = remaining_input % alphabet_length
  let input_rest = remaining_input / alphabet_length

  let assert Ok(next_char) = dict.get(alphabet_map, remainder)
  let new_acc = next_char <> acc

  case input_rest {
    0 -> new_acc
    _ -> recurse_encode(input_rest, alphabet_map, alphabet_length, new_acc)
  }
  // should trigger TCO
}

fn decode(
  input: String,
  reverse_alphabet_map: Dict(String, Int),
  alphabet_size: Int,
) -> Result(BitArray, Nil) {
  {
    use acc, current_letter <- list.try_fold(input |> string.to_graphemes, 0)
    use character_value <- result.try(dict.get(
      reverse_alphabet_map,
      current_letter,
    ))
    Ok(acc * alphabet_size + character_value)
  }
  |> result.map(fn(integer_result) { integer_result |> do_encode_unsigned })
}

fn alphabet_to_map(alphabet: List(String)) -> Dict(Int, String) {
  alphabet
  |> list.index_fold(dict.new(), fn(acc, letter, index) {
    dict.insert(acc, index, letter)
  })
}

fn map_reverse(map: Dict(a, b)) -> Dict(b, a) {
  let keys = dict.keys(map)
  let values = dict.values(map)
  let assert Ok(zipped) = list.strict_zip(values, keys)
  dict.from_list(zipped)
}

@external(erlang, "binary", "decode_unsigned")
fn do_decode_unsigned(input: BitArray) -> Int

@external(erlang, "binary", "encode_unsigned")
fn do_encode_unsigned(input: Int) -> BitArray
