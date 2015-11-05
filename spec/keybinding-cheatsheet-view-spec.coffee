path = require 'path'
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
      command: 'core:cancel'
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
      keystrokes: 'ctrl-w'
      command: 'core:cancel'
      selector: '.platform-win32 .go-to-line .mini-editor .input'
    }
    {
      source: bindingSource
      keystrokes: 'ctrl-w'
      command: 'core:cancel'
      selector: '.platform-linux .go-to-line .mini-editor .input'
    }
    {
      source: bindingSource
      keystrokes: 'ctrl-g'
      command: 'go-to-line:toggle'
      selector: '.platform-darwin, .platform-win32, .platform-linux'
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
    atom.config.set 'keybinding-cheatsheet.sortKeybindingsBy', 'keystrokes'
    atom.config.set 'keybinding-cheatsheet.alwaysShowGroups', []
    atom.config.set 'keybinding-cheatsheet.alwaysHideGroups', []
    atom.config.set 'keybinding-cheatsheet.hideAllOthers', false
    atom.config.set 'keybinding-cheatsheet.alwaysHideGroups', []
    expect(atom.keymaps).toBeDefined()

  describe 'when loading keybindings', ->

    beforeEach ->
      keyBindings = []
      keyBindings.push coreKeyBindingsWithPlatforms...
      keyBindings.push editorKeyBindings...
      keyBindings.push nativeKeyBindings...
      spyOn(atom.keymaps, 'getKeyBindings').andReturn keyBindings
      view = new KeybindingCheatsheetView

    it "loads keybindings", ->
      expect(atom.keymaps.getKeyBindings).toHaveBeenCalled()
      expect(view.keyBindings.length).not.toEqual 0

    it 'should exclude other platform bindings', ->
      expect(view.find('.keybinding').length).toEqual(6)
      for b in view.keyBindings
        if b.selector.indexOf('.platform') >= 0
          expect(b.selector.indexOf(".platform-#{process.platform}") >= 0).toBeTruthy()

    it 'should exclude native bindings', ->
      for b in view.keyBindings
        expect(b.command).not.toEqual 'native!'

    it "sorts keybindings by keystrokes", ->
      expect(view.keyBindings[0].keystrokes).toEqual 'alt-d'

  describe 'always showing groups', ->

    beforeEach ->
      keyBindings = []
      keyBindings.push editorKeyBindings...
      keyBindings.push coreKeyBindingsWithPlatforms...
      atom.config.set 'keybinding-cheatsheet.alwaysShowGroups', ['editor']
      spyOn(atom.keymaps, 'getKeyBindings').andReturn keyBindings
      view = new KeybindingCheatsheetView

    it 'shows them by default', ->
      count = 0
      for b in view.keyBindings
        if b.command.split(':')[0] == 'editor'
          ++count
      expect(count).toEqual(3)

    it 'shows them when search does not match', ->
      view.filterEditorView.setText('core')
      view.update()
      count = 0
      for b in view.keyBindings
        if b.command.split(':')[0] == 'editor'
          ++count
      expect(count).toEqual(3)

  describe 'always hide groups', ->

    beforeEach ->
      keyBindings = []
      keyBindings.push editorKeyBindings...
      atom.config.set 'keybinding-cheatsheet.alwaysHideGroups', ['editor']
      spyOn(atom.keymaps, 'getKeyBindings').andReturn keyBindings
      view = new KeybindingCheatsheetView

    it 'does not show them by default', ->
      expect(view.find('.keybinding').length).toEqual(0)

    it 'does not show them when search matches', ->
      view.filterEditorView.setText('editor')
      expect(view.find('.keybinding').length).toEqual(0)
