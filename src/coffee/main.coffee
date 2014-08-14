# Classes and such
class Card
  el : {}
  constructor:(@publicProperties)->

  # TODO:
  # tags

  template:->
    $('#card-template').html()

  render:->
    @el.remove() if @el.remove
    @el= $(Mustache.render(@template(), @publicProperties))
    @applyHandlers()

  applyHandlers: ->
    self = @
    self.el.on 'click', 'input[name=chosen]', (e)->
      self.publicProperties['chosen'] = self.el.find('input[name=chosen]:checked').val()
      self.el.trigger('card:updated')


class Toggle
  @state = true

  constructor:(@el)->
    @target = @el.data('target')
    @el.on 'click', {self:@}, @toggle

  toggle:(e)->
    @state = !@state
    e.data.self.el.toggleClass('selected')
    # emit an event to tell the filters to update
    $('.sidebar').trigger('toggle:clicked', e.data.self)

class FiltersController

  constructor:(@el)->
    self = @
    @filters = []
    @el.on 'toggle:clicked', {self:self}, @update
    $('.candidates').on 'card:updated', (e)->
      self.filter()

  update:(e, toggle)->
    filterIndex = e.data.self.filters.indexOf(toggle.target)
    if filterIndex > -1
      e.data.self.filters.splice(filterIndex, 1)
    else
      e.data.self.filters.push(toggle.target)
    e.data.self.filter()

  filter:->
    if @filters.length > 0
      for card in window.cards
        card.el.hide()
        for filter in @filters
          k = filter.match(/^(.*)\:/)[1]
          v = filter.match(/\:(.*)$/)[1]
          if (card.publicProperties[k] == v) or (card.publicProperties['tags'].indexOf(v) > -1)
            card.el.show()
            break
    else
      for card in window.cards
        card.el.show()


# This is where the magic happens
$ ->
  # create a bunch of cards and render them
  window.cards = for candidate in window.candidates
    new Card(candidate)
  
  for card in window.cards
    card.render()
    $('.candidates').append(card.el)

  window.toggles = for toggle in $('.toggle')
    new Toggle($(toggle))

  filtersController = new FiltersController($('.sidebar'))

  # collect tags from candidates. create toggle for each, insert in tags list
  tags = []
  for candidate in window.candidates
    tags = tags.concat candidate.tags
  tags = $.unique(tags)

  for tag in tags
    tmp = Mustache.render($('#tag-toggle-template').html(), {name:tag})
    toggle = new Toggle($(tmp))
    $('#tags').append($('<li></li>').append(toggle.el))

