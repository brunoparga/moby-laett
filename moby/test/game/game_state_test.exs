defmodule Moby.GameStateTest do
  use ExUnit.Case

  alias Moby.{GameState, Player}

  describe "state/1" do
    test "just returns its argument" do
      game = GameState.initialize()

      assert GameState.state(game) == game
    end
  end

  describe "initialize/0" do
    test "starts a new game" do
      actual = GameState.initialize()

      assert %GameState{
        players: [
          %Player{
            name: "Joe",
            current_cards: joe_current_cards,
            played_cards: [],
            active?: true,
            protected?: false
          },
          %Player{
            name: "Ann",
            current_cards: ann_current_cards,
            played_cards: [],
            active?: true,
            protected?: false
          }
        ],
        deck: deck,
        removed_card: removed_card,
        winner: nil,
        latest_move: nil,
        target_player: nil
      } = actual

      sorted_deck = ~w[baron baron countess guard guard guard guard guard handmaid
        handmaid king priest priest prince prince princess]a

      actual_cards =
        joe_current_cards ++
        ann_current_cards ++
        deck ++
        [removed_card]
        |> Enum.sort

        assert actual_cards == sorted_deck
    end
  end

  describe "set_move/2" do
    setup do
      game = %GameState{
        players: [
          %Player{
            name: "Joe",
            current_cards: [:hamdmaid, :king],
            played_cards: [],
            active?: true,
            protected?: false
          },
          %Player{
            name: "Ann",
            current_cards: [:prince],
            played_cards: [],
            active?: true,
            protected?: false
          }
        ],
        deck: Enum.shuffle(~w[princess countess prince handmaid baron baron priest guard guard guard guard guard]a),
        removed_card: :priest,
        winner: nil,
        latest_move: nil,
        target_player: nil
      }

      [game: game]
    end

    test "accepts a move with a valid non-targeted card", context do
      move = %{played_card: :handmaid}
      expected = %GameState{context[:game] | latest_move: move}

      actual = GameState.set_move(context[:game], move)

      assert actual == expected
    end

    test "accepts a move with a valid targeted card", context do
      game = %GameState{players: [_joe, ann]} = context[:game]
      move = %{played_card: :king, target: "Ann"}
      expected = %GameState{game | latest_move: move, target_player: ann}

      actual = GameState.set_move(game, move)

      assert actual == expected
    end

    test "accepts a move with a valid card but invalid target", context do
      game = %GameState{players: [joe, _ann]} = context[:game]
      move = %{played_card: :king, target: "Joe"}
      expected = %GameState{game | latest_move: move, target_player: joe}

      actual = GameState.set_move(game, move)

      assert actual == expected
    end

    test "accepts even a move with an invalid card", context do
      move = %{played_card: :ace_of_spades}
      expected = %GameState{context[:game] | latest_move: move}

      actual = GameState.set_move(context[:game], move)

      assert actual == expected
    end
  end
end
