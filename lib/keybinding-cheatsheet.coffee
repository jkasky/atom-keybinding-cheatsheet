KeybindingCheatsheetView = require './keybinding-cheatsheet-view'

module.exports =
  keybindingCheatsheetView: null
  configDefaults:
    showOnRightSide: true

  activate: (state) ->
    @keybindingCheatsheetView = new KeybindingCheatsheetView(state.keybindingCheatsheetViewState)

  deactivate: ->
    @keybindingCheatsheetView.destroy()

  serialize: ->
    keybindingCheatsheetViewState: @keybindingCheatsheetView.serialize()
