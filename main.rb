require 'rubygems'
require 'sinatra'
require 'pry'
set :sessions, true

=begin
  Logic:
    x Welcome page
      x ask user for name
      x start bank at $500; bank persists from game to game
    x bet page
      x user bets part of his bank
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


  Progression:
    welcome -> new_game -> bet -> calc ->show_hands

=end

# TODO: code hit and stay methods


helpers do
  # TODO: def to draw/hit cards
  def hit(player_hand, deck)

  end

  def show_card_image(card)
    suit = card[1]
    value = card[0]

    if card[0] == "Hidden"
      "<img src='/images/cards/cover.jpg'>    "
    else
      "<img src='/images/cards/#{suit}_#{value}.jpg'>    "
    end
  end

  def show_hand_total(hand)
    sum = 0
    face_cards = %w(jack queen king)
    num_aces = 0
    hand.each do |card|
      if card[0] == "Hidden"
        nil
      elsif face_cards.include? card[0]
        sum += 10
      elsif card[0] == "ace"
        sum += 11
        num_aces += 1
      else
        sum += card[0].to_i
      end
    end

    while sum > 21 and num_aces > 0
      sum = sum - 11 + 1
      num_aces -= 1
    end

    sum
  end

end

get "/welcome" do
  session[:user_bank] = 500
  erb :welcome
end

post '/new_game' do
  # TODO: create deck
  suits = %w(diamonds spades hearts clubs)
  values = %w(ace 2 3 4 5 6 7 8 9 10 jack queen king)
  deck = []
  suits.each do |suit|
    values.each do |value|
      deck << [value,suit]
    end
  end
  deck.shuffle!

  user_hand = []
  user_hand << deck.pop << deck.pop
  dealer_hand = []
  dealer_hand << deck.pop << deck.pop

  session[:deck] = deck
  session[:user_hand] = user_hand
  session[:dealer_hand] = dealer_hand
  session[:user_stay] = false
  session[:over_bet] = false
  session[:name] = params[:name].capitalize

  redirect '/bet'
end

get '/bet' do

  erb :bet
end

post '/calc' do

  session[:bet] = params[:bet].to_i

  if session[:bet] > session[:user_bank]
    session[:over_bet] = true
    redirect '/bet'
  else
    redirect '/show_hands'
  end
end

get '/show_hands' do

  if !session[:user_stay]
    @dealer_hand = session[:dealer_hand]
    @dealer_hand[1] = ["Hidden"]

    @user_hand = session[:user_hand]

    erb :show_hands
  else
    @dealer_hand = session[:dealer_hand]
    @user_stay = session[:user_hand]
  end

end

get '/user_hit' do
  "test"
end
