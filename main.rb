require 'rubygems'
require 'sinatra'
require 'pry'
set :sessions, true

helpers do

  def dealer_hits
    session[:dealer_hand] << session[:deck].pop
  end

  def find_winner
    user_sum = show_hand_total(session[:user_hand])
    dealer_sum = show_hand_total(session[:dealer_hand])

    if user_sum > dealer_sum
      winner = :user
    elsif user_sum < dealer_sum
      winner = :dealer
    else
      winner = :push
    end

    session[:winner] = winner
  end

  def bust?(hand)
    if show_hand_total(hand) > 21
      true
    else
      false
    end
  end

  def show_card_image(card)
    suit = card[1]
    value = card[0]

    if card[0] == "Hidden"
      "<img src='/images/cards/cover.jpg' style='border: 2px solid black'>    "
    else
      "<img src='/images/cards/#{suit}_#{value}.jpg' style='border: 2px solid black'>    "
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
  session[:bet_zero] = false
  session[:user_bank] = 500
  session[:first_game] = true

  erb :welcome
end

post '/store_name' do
  if params[:name] == ''
    session[:no_name] = true
    redirect '/invalid_name'
  else
    if session[:first_game]
      session[:name] = params[:name].capitalize
    end
  end
  redirect '/new_game'
end

get '/invalid_name' do
  redirect '/welcome'
end

get '/new_game' do
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

  value = dealer_hand[1][0]
  suit = dealer_hand[1][1]
  session[:hidden_card] = [value,suit]

  if session[:first_game]
    session[:user_bank] = 500
  end

  session[:deck] = deck
  session[:user_hand] = user_hand
  session[:user_bust] = false
  session[:dealer_hand] = dealer_hand
  session[:dealer_bust] = false
  session[:dealers_turn] = false
  session[:user_stay] = false
  session[:dealer_stay] = false
  session[:over_bet] = false
  session[:winner] = nil

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
  elsif session[:bet] <= 0
    session[:bet_zero] = true
    redirect '/bet'
  else
    redirect '/show_hands'
  end
end

get '/show_hands' do
  if !session[:user_stay]
    session[:dealer_hand][1][0] = "Hidden"
  else
    session[:dealer_hand][1] = session[:hidden_card]
    session[:dealers_turn] = true
  end
  erb :show_hands
end

get '/dealer_plays' do
  session[:dealers_turn] = true

  # If dealer's hand is less than 17, hit
  if show_hand_total(session[:dealer_hand]) < 17
    dealer_hits()
  end

  # Dealer stays above 16
  if show_hand_total(session[:dealer_hand]) >= 17
    session[:dealer_stay] = true
    session[:dealer_bust] = true if show_hand_total(session[:dealer_hand]) > 21 # Toggle dealer_bust
    find_winner()
  end
  erb :show_hands

end

get '/user_hit' do
  session[:user_hand] << session[:deck].pop
  bust?(session[:user_hand]) == true ? session[:user_bust] = true : nil
  redirect '/show_hands'
end

get '/user_stay' do
  session[:user_stay] = true
  redirect '/show_hands'
end

get '/payouts' do
  bet = session[:bet]

  if session[:user_bust]
    session[:user_bank] -= bet
  elsif session[:dealer_bust]
    session[:user_bank] += bet
  else
    if session[:winner] == :user
      session[:user_bank] += bet
    elsif session[:winner] == :dealer
      session[:user_bank] -= bet
    end
  end

  redirect '/new_game'
end
