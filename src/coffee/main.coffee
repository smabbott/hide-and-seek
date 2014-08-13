# Classes and such
class Card
  el : {}
  constructor:(@publicProperties)->

  # TODO:
  # tags

  template:->
    list = for prop in Object.keys(@publicProperties)
      "<dt>" + prop + "</dt><dd>{{" + prop + "}}</dd>"

    base = $($('#card-template').html())
    base.find('.properties').append(list.join(''))
    base

  render:->
    @el= $(Mustache.render($("<div></div>").append(@template()).html(), @publicProperties))


class Toggle
  constructor:->

  # TODO:
  # render

# This is where the magic happens
$ ->
  
  # create a bunch of cards and render them
  window.cards = for candidate in window.candidates
    new Card(candidate)
  for card in window.cards
    card.render()
    $('.candidates').append(card.el)

  # apply behavior to category toggles

  # run trough properties 
