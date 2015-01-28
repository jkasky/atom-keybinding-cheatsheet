{CompositeDisposable} = require 'atom'
KeybindingCheatsheetView = require './keybinding-cheatsheet-view'


module.exports =

  config:
    showOnRightSide:
      type: 'boolean'
      default: true
    sortKeybindingsBy:
      type: 'string'
      default: 'keystrokes'

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
