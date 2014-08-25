KeybindingCheatsheetView = require './keybinding-cheatsheet-view'

module.exports =
  keybindingCheatsheetView: null
  configDefaults:
    showOnRightSide: true
    sortKeybindingsBy: 'keystrokes'

  activate: (state) ->
    @keybindingCheatsheetView = new KeybindingCheatsheetView(state.keybindingCheatsheetViewState)

  deactivate: ->
    @keybindingCheatsheetView.destroy()

  serialize: ->
    keybindingCheatsheetViewState: @keybindingCheatsheetView.serialize()
