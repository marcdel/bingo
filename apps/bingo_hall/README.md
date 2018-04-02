# BingoHall

## Installation

1. Install Elixir dependencies:

    ```sh
    mix deps.get
    ```

2. Install Node.js dependencies: 

    ```sh
    cd assets && npm install
    ```

3. Install Elm dependencies:

    ```sh
    cd assets/elm && elm-package install -y
    ```

4. Make sure the assets build:

    ```sh
    cd assets && node node_modules/.bin/brunch build
    ```

5. Make sure all the tests pass:

    ```sh
    mix test
    ```

6. Fire up the Phoenix endpoint:

    ```sh
    mix phx.server
    ```

7. Visit [`localhost:4000`](http://localhost:4000) to play the game!
