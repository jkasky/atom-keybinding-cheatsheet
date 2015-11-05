{CompositeDisposable} = require 'atom'
{$, View, ScrollView, TextEditorView} = require 'atom-space-pen-views'
_ = require 'underscore-plus'


module.exports =
class KeybindingCheatsheetView extends View
  @content: ->
    @div class: 'keybinding-cheatsheet tool-panel', 'data-show-on-right-side': atom.config.get('keybinding-cheatsheet.showOnRightSide'), =>
      @div class: 'keybinding-panel-header', =>
        @h2 'Keybindings'
        @subview 'filterEditorView', new KeybindingFilterEditorView(mini: true)
      @div class: 'keybinding-panel-content', =>
        @subview 'listView', new KeybindingListView()

  initialize: (state) ->
    @platformSelector = new RegExp("\\.platform-#{process.platform}")
    @otherPlatformSelector = new RegExp("\\.platform-(?!#{process.platform})")

    @filterEditorView.getModel().setPlaceholderText('Filter keybindings')

    @filterEditorView.getModel().getBuffer().onDidStopChanging =>
      @update()

    atom.keymaps.onDidReloadKeymap =>
      @loadKeyBindings()
      @update()

    atom.keymaps.onDidUnloadKeymap =>
      @loadKeyBindings()
      @update()

    atom.config.observe 'keybinding-cheatsheet.sortKeybindingsBy', =>
      @loadKeyBindings()
      @update()

    @loadKeyBindings()
    @update()

  attached: ->
    @disposables = new CompositeDisposable

    @disposables.add atom.commands.add @element,
      'core-cancel': @toggle
      'core:move-down': @down
      'core:move-up': @up

    @disposables.add atom.commands.add 'atom-workspace',
      'core:cancel': @toggle

  detached: ->
    @disposables?.dispose()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  toggle: =>
    if @isVisible()
      # Restore the focus to the last focused elment if any part of the
      # cheatsheet currently has the focus.
      if @find(':focus').length && @lastFocusedElement?.isOnDom()
        @lastFocusedElement.focus()
      @detach()
    else
      @lastFocusedElement = $(':focus')
      @show()

  down: =>
    @listView.element.scrollTop += 20

  up: =>
    @listView.element.scrollTop -= 20

  loadKeyBindings: ->
    self = this
    sortKey = atom.config.get('keybinding-cheatsheet.sortKeybindingsBy')
    @keyBindings = _.reject(
      _.sortBy(atom.keymaps.getKeyBindings(), sortKey),
      (binding) =>
        if binding.command == 'native!'
          return true
        if !@platformSelector.test(binding.selector) &&
            @otherPlatformSelector.test(binding.selector)
          return true
        return false
    )

  update: ->
    @listView.empty()
    for b in @keyBindings
      continue unless @shouldShowBinding(b)
      [pkg, command] = b.command.split ':'
      group = @listView.find("[data-keybinding-group='#{pkg}']")?.view()
      if !group
        group = new KeybindingGroupView(pkg)
        @listView.append(group)
      group.items.append(new KeybindingView(b))

  shouldShowBinding: (binding) ->
    filterText = @filterEditorView.getText()
    if filterText
      {command, keystrokes, selector, source} = binding
      if "#{command}#{keystrokes}#{selector}#{source}".indexOf(filterText) == -1
        return false

    [pkg, command] = binding.command.split ':'
    if pkg in atom.config.get('keybinding-cheatsheet.alwaysShowGroups')
      return true
    if pkg in atom.config.get('keybinding-cheatsheet.alwaysHideGroups')
      return false
    if atom.config.get('keybinding-cheatsheet.hideAllOthers') &&
        !(pkg in atom.config.get('keybinding-cheatsheet.exceptFor'))
      return false

    return true

  deactivate: ->
      @remove()

  show: ->
    @attach() unless @hasParent()
    @lastFocused = @filterEditorView.focus()

  attach: ->
    return unless atom.project.getPaths()
    workspaceView = atom.views.getView(atom.workspace)
    if atom.config.get('keybinding-cheatsheet.showOnRightSide')
      @removeClass('panel-left')
      @addClass('panel-right')
      atom.workspace.addRightPanel(item: this)
    else
      @removeClass('panel-right')
      @addClass('panel-left')
      atom.workspace.addLeftPanel(item: this)


class KeybindingFilterEditorView extends TextEditorView

  setFontSize: (fontSize) ->
    fontSize = parseInt(fontSize) or 0
    fontSize = Math.min(32, fontSize)
    fontSize = Math.max(10, fontSize)
    super(fontSize)


class KeybindingListView extends ScrollView
  @content: ->
    @div class: 'keybinding-list'

  initialize: (serializeState) ->
    super


class KeybindingGroupView extends View
  @content: ->
    @div class: 'keybinding-group', =>
      @h2 class: 'keybinding-group-header', outlet: 'header'
      @div class: 'keybinding-group-items', outlet: 'items'

  initialize: (name) ->
    @attr('data-keybinding-group', name)
    @header.text(name)


class KeybindingView extends View
  @content: ->
    @div class: 'keybinding', =>
      @div class: 'keybinding-keystrokes', outlet: 'keystrokes'
      @div class: 'keybinding-command', outlet: 'command'

  initialize: (@binding) ->
    @keystrokes.text(@binding.keystrokes)
    [pkg, command] = binding.command.split ':'
    @command.text(command)
    @attr('title', 'Selector ' + binding.selector)
