async function get_gamestate(game) {
   const response = await fetch(`?game=${game}`)
   const state = await response.json();
   return state
}
async function post_update(uid, key, game, update) {
   const response = await fetch(`?gameupdate=${game}`, {
      headers: {
         "Content-Type": "application/json",
      },
      method: "POST",
      body: JSON.stringify({
         "uid": uid,
         "update": update,
         "key": key
      })
   })
}
