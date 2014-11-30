$(document).ready(function(){

  // show dealer's next card
  $(document).on('click', '#show_dealer_card_form input', function(){
    $.ajax({
      type: 'GET',
      url: '/dealer_plays',
    }).done(function(msg){
      $('#game').replaceWith(msg);
    });
    return false;
  });

  // user hits
  $(document).on('click', '#hit_form input', function(){
    $.ajax({
      type: 'GET',
      url: '/user_hit',
    }).done(function(msg){
      $('#game').replaceWith(msg);
    });
    return false;
  });

  // user stays
  $(document).on('click', '#stay_form input', function(){
    $.ajax({
      type: 'GET',
      url: '/user_stay',
    }).done(function(msg){
      $('#game').replaceWith(msg);
    });
    return false;
  });






});
