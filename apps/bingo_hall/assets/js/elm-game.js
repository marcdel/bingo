const gameContainer = document.getElementById("game-container")

if (gameContainer) {
  Elm.Bingo.embed(gameContainer, {
    gameName: gameContainer.getAttribute("data-game-name"),
    authToken: gameContainer.getAttribute("data-auth-token"),
    wsUrl: gameContainer.getAttribute("data-ws-url")
  })
}
