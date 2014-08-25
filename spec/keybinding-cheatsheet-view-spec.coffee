path = require 'path'
KeybindingCheatsheetView = require '../lib/keybinding-cheatsheet-view'

describe "KeybindingCheatsheetView", ->
  [keyBindings, view] = []
  bindingSource = "#{atom.getLoadSettings().resourcePath}#{path.sep}keymaps"

  beforeEach ->
    expect(atom.keymap).toBeDefined()
    keyBindings = [
      {
        source: bindingSource
        kestrokes: 'alt-h'
        command: 'editor:delete-to-beginning-of-word'
        selector: '.editor'
      }
      {
        source: bindingSource
        kestrokes: 'alt-delete'
        command: 'editor:delete-to-end-of-word'
        selector: '.editor'
      }
      {
        source: bindingSource
        kestrokes: 'alt-d'
        command: 'editor:delete-to-end-of-word'
        selector: '.editor'
      }
      {
        source: bindingSource
        keystrokes: 'cmd-a'
        command: 'core:select-all'
        selector: '.editor'
      }
      {
        source: bindingSource
        keystrokes: 'cmd-w'
        command: 'core-cancel'
        selector: '.platform-darwin .go-to-line .mini-editor .input'
      }
      {
        source: bindingSource
        keystrokes: 'cntrl-w'
        command: 'core-cancel'
        selector: '.platform-win32 .go-to-line .mini-editor .input'
      }
      {
        source: bindingSource
        keystrokes: 'cntrl-w'
        command: 'core-cancel'
        selector: '.platform-linux .go-to-line .mini-editor .input'
      }
    ]

    spyOn(atom.keymap, 'getKeyBindings').andReturn(keyBindings)
    view = new KeybindingCheatsheetView

  it "loads keybindings", ->
