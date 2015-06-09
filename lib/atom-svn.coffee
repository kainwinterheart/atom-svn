AtomSvnView = require './atom-svn-view'
AtomSvnAPI = require './svn.coffee'

module.exports =
  atomSvnView: null

  activate: (state) ->
    @atomSvnView = new AtomSvnView(state.atomSvnViewState)
    atom.commands.add 'atom-workspace', 'atom-svn:diff': -> AtomSvnAPI.diff()
    atom.commands.add 'atom-workspace', 'atom-svn:add': -> AtomSvnAPI.add()
    atom.commands.add 'atom-workspace', 'atom-svn:update': -> AtomSvnAPI.update()
    atom.commands.add 'atom-workspace', 'atom-svn:log': -> AtomSvnAPI.log()
    atom.commands.add 'atom-workspace', 'atom-svn:blame': -> AtomSvnAPI.blame()

  deactivate: ->
    @atomSvnView.destroy()

  serialize: ->
    atomSvnViewState: @atomSvnView.serialize()
