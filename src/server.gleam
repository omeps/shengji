import gleam/string
import gleam/result
import gleam/http
import gleam/io
import gleam/http/cowboy
import gleam/http/response.{type Response}
import gleam/http/request.{type Request}
import gleam/bytes_builder.{type BytesBuilder}
import gleam/erlang/process
import gleam/list
import file_streams/file_stream
pub fn content_type(path: String) -> String {
  path |> string.split(".") |> list.last() |> result.map(fn(x) {
    case x {
       "js" -> "text/javascript" 
       "css" -> "text/css" 
       "html" -> "text/html" 
       "md" -> "text/markdown" 
       _ -> "text/plain"
      
    }
  })|> result.unwrap("text/plain")
}
pub fn http_service(re: Request(t)) -> Response(BytesBuilder) {
 let path = re.path 
      |> fn(x) { 
        case string.contains(x,"..") || string.contains(x,"$") || string.contains(x,"~") {
          True -> "client/404.html"
          False -> case x {
             "/" -> "client/index.html"
             _ -> "client" <> x
           }
        }
      }
 
 let #(body,contype) = case http.method_to_string(re.method) {
  _-> path
      |> file_stream.open_read()
      |> result.map(fn(x) {#(x, content_type(path))})
      |> result.or(file_stream.open_read("client/404.html") |> result.map(fn(x) {#(x,content_type(".html"))}))
      |> result.map(fn(r) { file_stream.read_remaining_bytes(r.0) |> result.map(fn(x) {#(x, r.1)}) })
      |> result.flatten()
      |> result.map(fn(r) { #(bytes_builder.from_bit_array(r.0),r.1) })
      |> result.lazy_unwrap(fn () {io.print("couldn't build request") #(bytes_builder.new(),content_type(""))})
 }
 response.new(200)
 |> response.set_header("Content-Type", contype <> "; "<>"charset=utf8")
 |> response.set_body(body)
}

// Start tit on port 3000 using the cowboy web server
//
pub fn main() {
  
  case cowboy.start(http_service,3000) {
   Ok(_) -> io.println("server up")
   Error(_) -> io.println("uh oh")
  }
  
  process.sleep_forever()
}
