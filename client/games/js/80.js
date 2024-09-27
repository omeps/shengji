async function main() {
var hand = new handHolder(document.getElementById("hand"), "hand_", true)
var trick_friend = new handHolder(document.getElementById("trick_friend"),"trick_friend_", false)
var trick_enemy_left = new handHolder(document.getElementById("trick_enemy_left"),"trick_enemy_left_",false)
var trick_enemy_right = new handHolder(document.getElementById("trick_enemy_right"),"trick_enemy_right_",false)
var trick_self = new handHolder(document.getElementById("trick_self"),"trick_self_",false)
let value = await get_gamestate()
console.log("cards are",value.cards)
value.cards.forEach((element) =>hand.insert(element[0],element[1]))
hand.sort(2)
}
main()
