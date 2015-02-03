AtomSvnView = require './atom-svn-view'
AtomSvnAPI = require './svn.coffee'

module.exports =
  atomSvnView: null

  activate: (state) ->
    @atomSvnView = new AtomSvnView(state.atomSvnViewState)
    atom.workspaceView.command 'atom-svn:diff', -> AtomSvnAPI.diff()
    atom.workspaceView.command 'atom-svn:add', -> AtomSvnAPI.add()
    atom.workspaceView.command 'atom-svn:update', -> AtomSvnAPI.update()
    atom.workspaceView.command 'atom-svn:log', -> AtomSvnAPI.log()
    atom.workspaceView.command 'atom-svn:blame', -> AtomSvnAPI.blame()

  deactivate: ->
    @atomSvnView.destroy()

  serialize: ->
    atomSvnViewState: @atomSvnView.serialize()
