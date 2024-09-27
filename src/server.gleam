import gleam/bit_array
import rsa_keys
import radish
import gleam/iterator
import file_streams/file_stream
import file_streams/file_stream_error
import gleam/erlang/process
import gleam/bytes_builder.{type BytesBuilder}
import wisp.{type Request, type Response, Bytes}
import gleam/http/response.{Response}
import gleam/io
import gleam/list
import gleam/option.{Some,None}
import gleam/result
import gleam/string
import wisp/wisp_mist
import mist
pub fn content_type(path: String) -> String {
  path
  |> string.split(".")
  |> list.last()
  |> result.map(fn(x) {
    case x {
      "js" -> "text/javascript"
      "css" -> "text/css"
      "html" -> "text/html"
      "md" -> "text/markdown"
      _ -> "text/plain"
    }
  })
  |> result.unwrap("text/plain")
}
fn request_from_file(file_and_contype: Result(#(file_stream.FileStream,String),file_stream_error.FileStreamError)) -> #(BytesBuilder, String){
  file_and_contype |> result.map(fn(r) {
            file_stream.read_remaining_bytes(r.0)
            |> result.map(fn(x) { #(x, r.1) })
          }) |> result.flatten()
          |> result.map(fn(r) { #(bytes_builder.from_bit_array(r.0), r.1) })
          |> result.lazy_unwrap(fn() {
            io.print("couldn't build request")
            #(bytes_builder.new(), content_type(""))
          })
}
pub fn http_service(re: Request, db_cli: process.Subject(radish.Message)) -> Response {
  let path =
    re.path
    |> fn(x) {
      case
        string.contains(x, "..")
        || string.contains(x, "$")
        || string.contains(x, "~")
      {
        True -> "client/404.html"
        False ->
          case x {
            "/" -> "client/index.html"
            _ -> "client" <> x
          }
      }
    }
  let is_get_gamestate =
    re.query
    |> option.map(fn(x) { x |> string.contains("game=") })
    |> option.unwrap(False)
  let is_get_new_pass = 
    re.query
    |> option.map(fn(x) {
      x |> string.split("new_uid=") 
        |> iterator.from_list() 
        |> iterator.at(1)
        |> result.map(fn(x) {x |> string.split("&") |> iterator.from_list() |> iterator.first() })
        |> result.flatten()
        |> result.map(fn(x) {Some(x)})
        |> result.unwrap(None)
    })
    |> option.flatten()
  let #(body, contype) = case is_get_gamestate,is_get_new_pass {
    False,None ->
          path
          |> file_stream.open_read()
          |> result.map(fn(x) { #(x, content_type(path)) })
          |> result.or(
            file_stream.open_read("client/404.html")
            |> result.map(fn(x) { #(x, content_type(".html")) }),
          )
          |> request_from_file()
    True,None -> #(bytes_builder.from_string("{\"cards\": [
        [\"DIAMOND\",2],
        [\"DIAMOND\",3],
        [\"DIAMOND\",4],
        [\"DIAMOND\",8],
        [\"DIAMOND\",7],
        [\"HEART\",6],
        [\"SPADE\",\"Q\"],
        [\"CLUB\",\"J\"],
        [\"BLACK_JOKER\",\"\"]
      ]}"),"application/json")
    True,Some(_) -> file_stream.open_read("client/404.html") |> result.map(fn(x) { #(x, content_type(".html"))}) |> request_from_file()
    False,Some(id) -> {
      let content = radish.exists(db_cli, [id], 128) 
        |> result.map(fn(x) { 
          case x == 0 {
            True -> Ok(Nil)
            False -> Error(True)
          }
        })
        |> result.unwrap(Error(False))
        |> result.map(fn(_) {
          let #(pubkey, privkey) = rsa_keys.generate_rsa_keys()
          radish.set(db_cli, id, pubkey.pem, 128) |> result.map(fn(_) {privkey}) |> result.map_error(fn(_) {False})
        })
        |> result.flatten() |> result.map(fn(x) { "{\"privkey\":\"" <> x.pem |> string.replace("\n"," ")<> "\"}"})
        |> result.unwrap("{\"privkey\": null}")
      #(bytes_builder.from_string(content), "application/json")
    }
  }
  response.new(200)
  |> response.set_header("Content-Type", contype <> "; " <> "charset=utf8")
  |> response.set_body(Bytes(body))
}

// Start tit on port 3000 using the cowboy web server
//
pub fn main() {
  let secret_key = wisp.random_string(64)
  let assert Ok(client) = radish.start(
    "localhost",
    6379,
    [radish.Timeout(128),radish.Auth("19741297434")]
  )
  let assert Ok(_) = 
    fn(x) { http_service(x,client) }
    |> wisp_mist.handler(secret_key)
    |> mist.new()
    |> mist.port(8080)
    |> mist.start_http()
  process.sleep_forever()
}
