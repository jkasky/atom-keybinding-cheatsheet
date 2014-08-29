{$, EditorView, ScrollView, View} = require 'atom'
_ = require 'underscore-plus'


module.exports =
class KeybindingCheatsheetView extends View
  @content: ->
    @div class: 'keybinding-cheatsheet tool-panel', 'data-show-on-right-side': atom.config.get('keybinding-cheatsheet.showOnRightSide'), =>
      @div class: 'keybinding-panel-header', =>
        @h2 'Keybinding Cheatsheet'
        @subview 'filterEditorView', new KeybindingFilterEditorView()
      @div class: 'keybinding-panel-content', =>
        @subview 'listView', new KeybindingListView()

  initialize: (serializeState) ->
    atom.workspaceView.command 'keybinding-cheatsheet:toggle', => @toggle()

    @otherPlatformSelector = new RegExp("\\.platform-(?!#{process.platform})")

    @filterEditorView.setPlaceholderText('Filter keybindings')

    @filterEditorView.getEditor().getBuffer().on 'contents-modified', =>
      @update()

    @subscribe atom.keymap, 'reloaded-key-bindings unloaded-key-bindings', =>
      @loadKeyBindings()
      @update()

    @subscribe atom.config.observe 'keybinding-cheatsheet.sortKeybindingsBy', =>
      @loadKeyBindings()
      @update()

    @loadKeyBindings()
    @update()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  toggle: ->
    if @hasParent()
      # Restore the focus to the last focused elment if any part of the
      # cheatsheet currently has the focus.
      if @find(':focus').length && @lastFocusedElement?.isOnDom()
        @lastFocusedElement.focus()
      @detach()
    else
      @lastFocusedElement = $(':focus')
      @show()

  loadKeyBindings: ->
    self = this
    sortKey = atom.config.get('keybinding-cheatsheet.sortKeybindingsBy')
    @keyBindings = _.reject(
      _.sortBy(atom.keymap.getKeyBindings(), sortKey),
      (binding) =>
        if binding.command == 'native!'
          return true
        if @otherPlatformSelector.test(binding.selector)
          return true
        return false
    )

  update: ->
    @listView.empty()
    for b in @keyBindings
      continue unless @shouldShowBinding(b)
      [pkg, command] = b.command.split ':'
      group = @listView.find("[data-keybinding-group=#{pkg}]")?.view()
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
    return true

  deactivate: ->
      @remove()

  show: ->
    @attach() unless @hasParent()
    @lastFocused = @filterEditorView.focus()

  attach: ->
    return unless atom.project.getPath()
    if atom.config.get('keybinding-cheatsheet.showOnRightSide')
      @removeClass('panel-left')
      @addClass('panel-right')
      atom.workspaceView.appendToRight(this)
    else
      @removeClass('panel-right')
      @addClass('panel-left')
      atom.workspaceView.appendToLeft(this)


class KeybindingFilterEditorView extends EditorView
  constructor: (options={}) ->
    options.mini = true
    super(options)

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
