function select_swap(id) {
  document.getElementById(id).classList.toggle("selected")
}
const Suits = Object.freeze({
  DIAMOND: Symbol("DIAMOND"),
  HEART: Symbol("HEART"),
  SPADE: Symbol("SPADE"),
  CLUB: Symbol("CLUB"),
  RED_JOKER: Symbol("RED_JOKER"),
  BLACK_JOKER: Symbol("BLACK_JOKER"),
})
function card_value (top_value,a) {
  console.log(`(${a[1]},${a[2]})'s value is:`)
  switch (a[1]) {
    case top_value: var a_v = 57;break;
    case "A": var a_v = 14;break;
    case "K": var a_v = 13;break;
    case "Q": var a_v = 12;break;
    case "J": var a_v = 11;break;
    default: var a_v = a[1];break;
  }
  switch (a[0]) {
    case Suits.BLACK_JOKER: var a = 101; break;
    case Suits.RED_JOKER: var a = 100; break;
    case Suits.DIAMOND: var a = a_v + 42; break;
    case Suits.SPADE: var a = a_v + 28; break;
    case Suits.HEART: var a = a_v + 14; break;
    case Suits.CLUB: var a = a_v; break;
  }
  console.log(a)
  return a;
}
class handHolder {
  //!assumes id_prefix is GUARANTEED TO BE UNIQUE!!
  constructor(hand,id_prefix) {
    this.cards = []
    this.id_prefix = id_prefix
    this.dom = hand
  }
  insert(suit,value) {
    let left = `${(this.cards.length * 2.0 + 0.5 )}%`
    this.dom.insertAdjacentHTML("beforeend", card_new(suit, value, left, `${this.id_prefix}${this.cards.length}`))
    this.cards.push([suit,value,`${this.id_prefix}${this.cards.length}`])
  }
  sort(top_value) {
    this.cards.sort(function(a,b) {return Math.sign(card_value(top_value,b)-card_value(top_value,a));})
    for(const [index,[suit,value,id]] of this.cards.entries()) {
      let card = document.getElementById(id)
      card.style.left = `${(index * 2.0 + 0.5 )}%`
      //push to top, bad hack
      this.dom.appendChild(card)
    }
  }
}
function card_new(suit, value, left, id) {
   
  switch (suit) {
    case Suits.DIAMOND: 
      var color = "red"
      console.log("diamong")
      var suit_char = "♦"
      break
    case Suits.HEART: 
      console.log("hart")
      var color = "red"
      var suit_char = "♥"
      break
    case Suits.SPADE: 
      var color = "black"
      var suit_char = "♠"
      break
    case Suits.CLUB: 
      var color = "black"
      var suit_char = "♣"
      break
    case Suits.BLACK_JOKER: 
      var color = "black"
      var value = '✪'
      var suit_char = ""
      break
    case Suits.RED_JOKER: 
      var color = "red"
      var value = '✪'
      var suit_char = ""
      break

  }
  return `<div id=${id} onclick="select_swap('${id}')"class="card ${color}" style="left:${left}">${value}<br> ${suit_char}</div>`;
  
}
