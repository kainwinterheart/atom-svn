AtomSvnView = require './atom-svn-view'

module.exports =
  atomSvnView: null

  activate: (state) ->
    @atomSvnView = new AtomSvnView(state.atomSvnViewState)

  deactivate: ->
    @atomSvnView.destroy()

  serialize: ->
    atomSvnViewState: @atomSvnView.serialize()
