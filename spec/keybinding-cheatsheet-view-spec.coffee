path = require 'path'
{WorkspaceView} = require 'atom'
KeybindingCheatsheetView = require '../lib/keybinding-cheatsheet-view'
_ = require 'underscore-plus'


describe "KeybindingCheatsheetView", ->

  bindingSource = "#{atom.getLoadSettings().resourcePath}#{path.sep}keymaps"

  editorKeyBindings = [
    {
      source: bindingSource
      keystrokes: 'alt-h'
      command: 'editor:delete-to-beginning-of-word'
      selector: '.editor'
    }
    {
      source: bindingSource
      keystrokes: 'alt-delete'
      command: 'editor:delete-to-end-of-word'
      selector: '.editor'
    }
    {
      source: bindingSource
      keystrokes: 'alt-d'
      command: 'editor:delete-to-end-of-word'
      selector: '.editor'
    }
  ]

  coreKeyBindingsWithPlatforms = [
    {
      source: bindingSource
      keystrokes: 'cmd-w'
      command: 'core-cancel'
      selector: '.platform-darwin .go-to-line .mini-editor .input'
    }
    {
      source: bindingSource
      keystrokes: 'cmd-a'
      command: 'core:select-all'
      selector: '.editor'
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

  nativeKeyBindings = [
    {
      source: bindingSource
      keystrokes: 'cmd-h'
      command: 'native!'
    }
  ]

  keyBindings = []
  view = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView()
    expect(atom.keymap).toBeDefined()

  describe 'when loading keybindings', ->

    beforeEach ->
      keyBindings = []
      keyBindings.push coreKeyBindingsWithPlatforms...
      keyBindings.push editorKeyBindings...
      keyBindings.push nativeKeyBindings...
      spyOn(atom.keymap, 'getKeyBindings').andReturn keyBindings
      spyOn(atom.config, 'get').andReturn 'keystrokes'
      view = new KeybindingCheatsheetView

    it "loads keybindings", ->
      expect(atom.keymap.getKeyBindings).toHaveBeenCalled()
      expect(view.keyBindings.length).not.toEqual 0

    it 'should exclude other platform bindings', ->
      expect(view.find('.keybinding').length).toEqual(5)
      for b in view.keyBindings
        expect(b.selector.indexOf '.platform-linux').toEqual -1
        expect(b.selector.indexOf '.platform-win32').toEqual -1

    it 'should exclude native bindings', ->
      for b in view.keyBindings
        expect(b.command).not.toEqual 'native!'

    it "sorts keybindings by keystrokes", ->
      expect(view.keyBindings[0].keystrokes).toEqual 'alt-d'
