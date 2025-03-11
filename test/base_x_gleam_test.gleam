import base_x_gleam
import gleam/list
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

type BaseTestCase {
  BaseTestCase(
    name: String,
    alphabet: String,
    encode_cases: List(EncodeTestCase),
    decode_cases: List(DecodeTestCase),
  )
}

type EncodeTestCase {
  EncodeTestCase(input: BitArray, expected_output: String)
}

type DecodeTestCase {

  DecodeTestCase(input: String, expected_output: Result(BitArray, Nil))
}

const test_cases = [
  BaseTestCase(
    name: "hexadecimal",
    alphabet: "0123456789ABCDEF",
    encode_cases: [
      EncodeTestCase(<<"foobar">>, "666F6F626172"),
      EncodeTestCase(<<"wibblewobble">>, "776962626C65776F62626C65"),
    ],
    decode_cases: [
      DecodeTestCase("invalid", Error(Nil)),
      DecodeTestCase("666F6F626172", Ok(<<"foobar">>)),
      DecodeTestCase("776962626C65776F62626C65", Ok(<<"wibblewobble">>)),
    ],
  ),
  BaseTestCase(
    name: "base58",
    alphabet: "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz",
    encode_cases: [
      EncodeTestCase(<<"foobar">>, "t1Zv2yaZ"),
      EncodeTestCase(<<"wibblewobble">>, "3FhSYN5Ra1ZtmGfAC"),
    ],
    decode_cases: [
      DecodeTestCase("invalid", Error(Nil)),
      DecodeTestCase("t1Zv2yaZ", Ok(<<"foobar">>)),
      DecodeTestCase("3FhSYN5Ra1ZtmGfAC", Ok(<<"wibblewobble">>)),
    ],
  ),
  BaseTestCase(
    name: "base64",
    alphabet: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/",
    encode_cases: [
      EncodeTestCase(<<"foobar">>, "Zm9vYmFy"),
      EncodeTestCase(<<"wibblewobble">>, "d2liYmxld29iYmxl"),
    ],
    decode_cases: [
      DecodeTestCase("invalid*", Error(Nil)),
      DecodeTestCase("Zm9vYmFy", Ok(<<"foobar">>)),
      DecodeTestCase("d2liYmxld29iYmxl", Ok(<<"wibblewobble">>)),
    ],
  ),
]

pub fn run_test() {
  let invalid_alphabet = "aabcde"
  // alphabets should not have duplicates
  base_x_gleam.generate(invalid_alphabet)
  |> should.be_error

  use base_case <- list.each(test_cases)
  let #(encoder, decoder) =
    base_x_gleam.generate(base_case.alphabet) |> should.be_ok
  run_encode_cases(encoder, base_case.encode_cases)
  run_decode_cases(decoder, base_case.decode_cases)
}

fn run_encode_cases(
  encoder: fn(BitArray) -> String,
  cases: List(EncodeTestCase),
) -> Nil {
  use test_case <- list.each(cases)

  test_case.input
  |> encoder
  |> should.equal(test_case.expected_output)
}

fn run_decode_cases(
  decoder: fn(String) -> Result(BitArray, Nil),
  cases: List(DecodeTestCase),
) -> Nil {
  use test_case <- list.each(cases)

  test_case.input
  |> decoder
  |> should.equal(test_case.expected_output)
}
