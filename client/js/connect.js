function get_gamestate(game) {
    var xmlHttp = new XMLHttpRequest();
    let data = new Promise (function(resolve,reject) {
        xmlHttp.onreadystatechange = function() { 
            if (xmlHttp.readyState == 4 && xmlHttp.status == 200){
                resolve(JSON.parse(xmlHttp.responseText));
            }
        }
    })
    xmlHttp.open("GET", `?game=${game}`, true); // true for asynchronous 
    xmlHttp.send(null);
    return data;
}
function make_rsa_key() {
    
}
function miller_rabin(n,k) {
    let c = ctz(n - 1n)
    let d = (n - 1n)
    for(let i = 0; i<k; i++) {

    }
}
function expmod( base, exp, mod ){
  if (exp == 0n) return 1n
  if (exp % 2n == 0n){
    return expmod( base, (exp / 2n), mod) ** 2n % mod
  }
  else {
    return (base * expmod( base, (exp - 1n), mod)) % mod
  }
}
function ctz(n) {
    let c = 0n
    while (n % 2n == 0n) {
        c += 1n
        n = n / 2n
    }
    return c;
}

