{CompositeDisposable} = require 'atom'
KeybindingCheatsheetView = require './keybinding-cheatsheet-view'


module.exports =

  config:
    showOnRightSide:
      order: 1
      type: 'boolean'
      default: true
    sortKeybindingsBy:
      order: 2
      type: 'string'
      default: 'keystrokes'

    alwaysShowGroups:
      order: 10
      type: 'array'
      default: []
      items:
        type: 'string'
    alwaysHideGroups:
      order: 11
      type: 'array'
      default: []
      items:
        type: 'string'
    hideAllOthers:
      order: 12
      type: 'boolean'
      default: 'false'
    exceptFor:
      order: 13
      type: 'array'
      default: []
      items:
        type: 'string'

  view: null

  activate: (@state) ->
    @disposables = new CompositeDisposable

    @disposables.add atom.commands.add('atom-workspace', {
      'keybinding-cheatsheet:toggle': => @getView().toggle()
    })

  deactivate: ->
    @disposables.dispose()
    @view?.deactivate()
    @view = null

  getView: ->
    unless @view?
      @view = new KeybindingCheatsheetView(@state)
    @view

  serialize: ->
    if @view?
      @view.serialize()
    else
      @state
