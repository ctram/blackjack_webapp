require 'rubygems'
require 'sinatra'

set :sessions, true

=begin
  Logic:
    Welcome page
      ask user for name
      start bank at $500; bank persists from game to game
    bet page
      user bets part of his bank
    user page:
      first deal:
        show initial cards for dealer and user
        one of dealer's cards is hidden
      user hits until he stays
      check for bust or stay
        if bust, go to --> win page
    dealer page:
      show dealer's hidden card
      button to advance dealer's move until he busts or stays
      dealer hits until he reaches 17
    win page:
      compute winner
      display who won or push
      ask whether player wants to play again
      move bank --> bet page

  session hash should include:
    - player's name
    - player's:
      - bank
      - cards
      - card totals
      - whether player has:
        - stayed
        - bust
        - win
     -dealer's
      - cards
      - card totals
      - whether player has:
        - stayed
        - bust
        - win

=end


helpers do
end

get "/"
