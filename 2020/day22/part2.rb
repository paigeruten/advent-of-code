chunks = DATA.read.split("\n\n")
deck1 = chunks[0].lines[1..-1].map(&:to_i)
deck2 = chunks[1].lines[1..-1].map(&:to_i)

# returns 1 if player1 won, or 2 if player2 won
def play_game(deck1, deck2)
  prev_card_configs = {}
  until deck1.empty? || deck2.empty?
    card_config = [[deck1.dup, deck2.dup]] # tip: never mutate an array that you're using as a hash key... >.<
    return 1 if prev_card_configs[card_config]
    prev_card_configs[card_config] = true

    card1, card2 = deck1.shift, deck2.shift

    if deck1.length < card1 || deck2.length < card2
      winner = card1 > card2 ? 1 : 2
    else
      winner = play_game(deck1[0...card1], deck2[0...card2])
    end

    if winner == 1
      deck1.push(card1, card2)
    else
      deck2.push(card2, card1)
    end
  end

  deck1.empty? ? 2 : 1
end

winner = play_game(deck1, deck2)

score = [deck1, deck2][winner-1].reverse.map.with_index { |card, i| (i+1) * card }.sum
p score

__END__
Player 1:
4
25
3
11
2
29
41
23
30
21
50
8
1
24
27
10
42
43
38
15
18
13
32
37
34

Player 2:
12
6
36
35
40
47
31
9
46
49
19
16
5
26
39
48
7
44
45
20
17
14
33
28
22
