{WorkspaceView} = require 'atom'
KeybindingCheatsheet = require '../lib/keybinding-cheatsheet'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "KeybindingCheatsheet", ->
  activationPromise = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    activationPromise = atom.packages.activatePackage('keybinding-cheatsheet')

  describe "when the keybinding-cheatsheet:toggle event is triggered", ->
    it "attaches and then detaches the view", ->
      expect(atom.workspaceView.find('.keybinding-cheatsheet')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.workspaceView.trigger 'keybinding-cheatsheet:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(atom.workspaceView.find('.keybinding-cheatsheet')).toExist()
        atom.workspaceView.trigger 'keybinding-cheatsheet:toggle'
        expect(atom.workspaceView.find('.keybinding-cheatsheet')).not.toExist()
