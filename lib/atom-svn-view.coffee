module.exports =
class AtomSvnView
    constructor: (serializeState) ->
        # Create root element
        @element = document.createElement('div')
        @element.classList.add('atom-svn',  'overlay', 'from-top')

        # Create message element
        message = document.createElement('div')
        message.textContent = "The AtomSvn package is Alive! It's ALIVE!"
        message.classList.add('message')
        @element.appendChild(message)

        # Register command that toggles this view
        # atom.commands.add 'atom-workspace', 'atom-svn:toggle': => @toggle()

    # Returns an object that can be retrieved when package is activated
    serialize: ->

    # Tear down any state and detach
    destroy: ->
        @element.remove()

    # Toggle the visibility of this view
    toggle: ->
        console.log 'AtomSvnView was toggled!'

        if @element.parentElement?
            @element.remove()
        else
            atom.workspaceView.append(@element)
