{ScrollView, View} = require 'atom'

module.exports =
class KeybindingCheatsheetView extends View
  @content: ->
    @div class: 'keybinding-cheatsheet tool-panel', 'data-show-on-right-side': atom.config.get('keybinding-cheatsheet.showOnRightSide'), =>
      @div class: 'keybinding-panel-header', =>
        @h2 'Keybinding Cheatsheet'
        @input type: 'text', class: 'keybinding-filter', outlet: 'filterField'
      @div class: 'keybinding-panel-content', =>
        @subview 'listView', new KeybindingListView()

  initialize: (serializeState) ->
    atom.workspaceView.command 'keybinding-cheatsheet:toggle', => @toggle()
    atom.workspaceView.command 'keybinding-cheatsheet:refresh', => @refresh()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  toggle: ->
    if @isVisible()
      @detach()
    else
      @show()

  refresh: ->
    return unless @isVisible()
    @update()

  update: ->
    @listView.empty()
    for b in atom.keymaps.keyBindings
      continue unless @shouldShowBinding(b)
      [pkg, command] = b.command.split ':'
      group = @listView.find("[data-keybinding-group=#{pkg}]")?.view()
      if !group
        group = new KeybindingGroupView(pkg)
        @listView.append(group)
      group.items.append(new KeybindingView(b))

  shouldShowBinding: (binding) ->
    return false if binding.command == 'native!'
    return true

  deactivate: ->
      @remove()

  show: ->
    # TODO: make this more efficient
    @update()
    @attach() unless @hasParent()
    @focus()

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


class KeybindingListView extends ScrollView
  @content: ->
    @div class: 'keybinding-list'

  initialize: (serializeState) ->
    super


class KeybindingGroupView extends View
  @content: ->
    @div class: 'keybinding-group', =>
      @h3 class: 'keybinding-group-header', outlet: 'header'
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
