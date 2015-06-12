{$} = require 'atom-space-pen-views'
KeybindingCheatsheet = require '../lib/keybinding-cheatsheet'


describe "KeybindingCheatsheet", ->
  [workspaceView, activationPromise] = []

  beforeEach ->
    workspaceView = atom.views.getView(atom.workspace)
    jasmine.attachToDOM(workspaceView)
    activationPromise = atom.packages.activatePackage('keybinding-cheatsheet')

  describe "when the keybinding-cheatsheet:toggle event is triggered", ->
    it "attaches/detaches", ->
      expect($(workspaceView).find('.keybinding-cheatsheet')).not.toExist()
      atom.commands.dispatch(workspaceView, 'keybinding-cheatsheet:toggle')

      waitsForPromise ->
        activationPromise

      runs ->
        expect($(workspaceView).find('.keybinding-cheatsheet')).toExist()

        atom.commands.dispatch(workspaceView, 'keybinding-cheatsheet:toggle')
        expect($(workspaceView).find('.keybinding-cheatsheet')).not.toExist()
