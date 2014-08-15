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

  constructor:(@el, @count = 0)->
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
      $('.toggle-yes').attr('disabled', self.categorizedAs('yes').length == 0)
      $('.toggle-maybe').attr('disabled', self.categorizedAs('maybe').length == 0)
      $('.toggle-no').attr('disabled', self.categorizedAs('no').length == 0)
      self.filter()

  update:(e, toggle)->
    filterIndex = e.data.self.filters.indexOf(toggle.target)
    if filterIndex > -1
      e.data.self.filters.splice(filterIndex, 1)
    else
      e.data.self.filters.push(toggle.target)
    e.data.self.filter()

  filter:->
    chosenFilters = @filters.filter (f)->
      return f.match(/chosen/)
    tagFilters = @filters.filter (f)->
      return f.match(/tag/)

    $('.categories').toggleClass('filtering', chosenFilters.length > 0)
    $('#tags').toggleClass('filtering', tagFilters.length > 0)
    # loop through all cards,
    # Each card must have at least one item from both chosen and tags 
    # unless either of those is empty

    if chosenFilters.length > 0 or tagFilters.length > 0
      # first hid all of the cards
      for card in window.cards
        card.el.hide()
        matchChosen = chosenFilters.length == 0
        matchTags   = tagFilters.length == 0

        for filter in chosenFilters
          k = filter.match(/^(.*)\:/)[1]
          v = filter.match(/\:(.*)$/)[1]
          if (card.publicProperties[k] == v)
            # card.el.show()
            matchChosen = true
            break

        for filter in tagFilters
          v = filter.match(/\:(.*)$/)[1]
          if (card.publicProperties['tags'].indexOf(v) > -1)
            # card.el.show()
            matchTags = true
            break

        card.el.show() if matchChosen and matchTags
    else
      for card in window.cards
        card.el.show()

  # TODO: use this method for filtering?
  taggedWith:(tag)->
    matches = window.cards.filter (card)->
      return card.publicProperties.tags.indexOf(tag) > -1

  # TODO: maybe this belongs in another controller
  # Maybe it can be merged with taggedWith() and used in filter
  categorizedAs:(category)->
    matches = window.cards.filter (card)->
      return card.publicProperties['chosen'] == category

# This is where it all kicks off
$ ->
  # create a bunch of cards and render them
  window.cards = for candidate in window.candidates
    new Card(candidate)
  
  for card in window.cards
    card.render()
    $('.candidates').append(card.el)

  window.toggles = for toggle in $('.toggle')
    new Toggle($(toggle))

  window.filtersController = new FiltersController($('.sidebar'))

  # collect tags from candidates. create toggle for each, insert in tags list
  tags = []
  for candidate in window.candidates
    tags = tags.concat candidate.tags
  tags = $.unique(tags)

  for tag in tags
    count = filtersController.taggedWith(tag).length
    tmp = Mustache.render($('#tag-toggle-template').html(), {name:tag, count:count})
    toggle = new Toggle($(tmp))
    $('#tags').append($('<li></li>').append(toggle.el))

