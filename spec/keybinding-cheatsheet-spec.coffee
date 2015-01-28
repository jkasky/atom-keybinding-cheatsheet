{$} = require 'atom-space-pen-views'
KeybindingCheatsheet = require '../lib/keybinding-cheatsheet'


describe "KeybindingCheatsheet", ->
  workspaceView = null

  beforeEach ->
    workspaceView = atom.views.getView(atom.workspace)
    jasmine.attachToDOM(workspaceView)

  describe "when the keybinding-cheatsheet:toggle event is triggered", ->
    it "attaches/detaches", ->

      waitsForPromise ->
        atom.packages.activatePackage('keybinding-cheatsheet')

      runs ->
        expect($(workspaceView).find('.keybinding-cheatsheet')).not.toExist()

        atom.commands.dispatch(workspaceView, 'keybinding-cheatsheet:toggle')
        expect($(workspaceView).find('.keybinding-cheatsheet')).toExist()

        atom.commands.dispatch(workspaceView, 'keybinding-cheatsheet:toggle')
        expect($(workspaceView).find('.keybinding-cheatsheet')).not.toExist()
