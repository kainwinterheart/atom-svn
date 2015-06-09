{Subscriber} = require 'emissary'
{BufferedProcess, $} = require 'atom'
{View} = require 'atom-space-pen-views'
fs = require 'fs-plus'
Os = require 'os'
Path = require 'path'

diffFilePath = Path.join Os.tmpDir(), "atom_svn.diff"
logFilePath = Path.join Os.tmpDir(), "atom_svn.log"
updateFilePath = Path.join Os.tmpDir(), "atom_svn.update"
blameFilePath = Path.join Os.tmpDir(), "atom_svn.blame"

class StatusView extends View
    Subscriber.includeInto(this)

    @content = (params) ->
        @div class: 'atom-svn overlay from-bottom', =>
            @div class: "#{params.type} message", params.message

    initialize: ->
        @subscribe $(window), 'core:cancel', => @detach()
        atom.workspaceView.append(this)
        setTimeout =>
            @detach()
        , ( atom.config.get('atom-svn.messageTimeout') ? 10 ) * 1000

    detach: ->
        super
        @unsubscribe()

svn =
    cmd: ( {args, opts, stdout, stderr, exit} = {} ) ->
        command = 'svn'
        opts ?= {}
        opts.cwd ?= atom.project.getPath()
        opts.env ?= process.env
        opts.env.LANG ?= ( atom.config.get('atom-svn.shellLang') ? 'en_US.UTF-8' )
        stderr ?= (data) ->
            str = data.toString()
            new StatusView(type: 'alert', message: str)
            console.log str

        if stdout? and not exit?
            c_stdout = stdout
            stdout = (data) ->
                @save ?= ''
                @save += data
            exit = (exit) ->
                c_stdout @save ?= ''
                @save = null

        new BufferedProcess
            command: command
            args: args
            options: opts
            stdout: stdout
            stderr: stderr
            exit: exit

    add: ( {file, stdout, stderr, exit} = {} ) ->
        file ?= this.relativize(atom.workspace.getActiveEditor()?.getPath())
        exit ?= (code) ->
            if code is 0
                new StatusView(type: 'success', message: "Added #{file ? 'all files'}")
        this.cmd
            args: ['add', file ? '.']
            stdout: stdout if stdout?
            stderr: stderr if stderr?
            exit: exit

    checkout: ->
        new StatusView(type: 'error', message: 'Not implemented.')

    delete: ->
        new StatusView(type: 'error', message: 'Not implemented.')

    status: ->
        new StatusView(type: 'error', message: 'Not implemented.')

    update: ( {file, stdout, stderr, exit} = {} ) ->
        self = this
        file ?= self.relativize(atom.workspace.getActiveEditor()?.getPath())

        new StatusView(type: 'success', message: "Updating #{file ? 'all files'}, please wait...")

        if file
            exit ?= (code) ->
                if code is 0
                    new StatusView(type: 'success', message: "Updated #{file}")
            this.cmd
                args: ['up', file]
                stdout: stdout if stdout?
                stderr: stderr if stderr?
                exit: exit
        else
            updateStat = ''
            this.cmd
                args: ['up', '.']
                stdout: stdout ? (data) -> updateStat += data
                stderr: stderr if stderr?
                exit: (code) -> self.prepFile( updateFilePath, updateStat ) if code is 0

    revert: ->
        new StatusView(type: 'error', message: 'Not implemented.')

    move: ->
        new StatusView(type: 'error', message: 'Not implemented.')

    commit: ->
        new StatusView(type: 'error', message: 'Not implemented.')

    diff: ( {file, stdout, stderr, exit} = {} ) ->
        self = this
        file ?= self.relativize(atom.workspace.getActiveEditor()?.getPath())
        diffStat = ''
        this.cmd
            args: ['diff', file ? '.']
            stdout: stdout ? (data) -> diffStat += data
            stderr: stderr if stderr?
            exit: (code) -> self.prepFile( diffFilePath, diffStat ) if code is 0

    log: ( {file, stdout, stderr, exit} = {} ) ->
        self = this
        file ?= self.relativize(atom.workspace.getActiveEditor()?.getPath())
        logStat = ''
        this.cmd
            args: ['log', file ? '.']
            stdout: stdout ? (data) -> logStat += data
            stderr: stderr if stderr?
            exit: (code) -> self.prepFile( logFilePath, logStat ) if code is 0

    blame: ( {file, stdout, stderr, exit} = {} ) ->
        self = this
        file ?= self.relativize(atom.workspace.getActiveEditor()?.getPath())
        blameStat = ''
        this.cmd
            args: ['blame', file ? '.']
            stdout: stdout ? (data) -> blameStat += data
            stderr: stderr if stderr?
            exit: (code) -> self.prepFile( blameFilePath, blameStat ) if code is 0

    # returns filepath relativized for either a submodule, repository or a project
    relativize: (path) ->
        atom.project.getRepo()?.relativize(path) ? atom.project.relativize(path)

    prepFile: (path, text) ->
        if text?.length > 0
            fs.writeFileSync path, text, flag: 'w+'
            this.showFile(path)
        else
            new StatusView(type: 'error', message: 'Nothing to show.')

    showFile: (path) ->
        split = if ( atom.config.get('atom-svn.openInPane') ? true ) then ( atom.config.get('atom-svn.splitPane') ? 'right' )
        atom.workspace
            .open(path, split: split, activatePane: true)

svn.up = svn.update
svn.ci = svn.commit

module.exports = svn
