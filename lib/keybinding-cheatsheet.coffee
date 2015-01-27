KeybindingCheatsheetView = require './keybinding-cheatsheet-view'

module.exports =
  keybindingCheatsheetView: null
  config:
    showOnRightSide:
      type: 'boolean'
      default: true
    sortKeybindingsBy:
      type: 'string'
      default: 'keystrokes'

  activate: (state) ->
    @keybindingCheatsheetView = new KeybindingCheatsheetView(state.keybindingCheatsheetViewState)

  deactivate: ->
    @keybindingCheatsheetView.destroy()

  serialize: ->
    keybindingCheatsheetViewState: @keybindingCheatsheetView.serialize()
