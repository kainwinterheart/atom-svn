{BufferedProcess} = require 'atom'
StatusView = require './views/status-view'

svn =
  cmd: ( {args, opts, stdout, stderr, exit} = {} ) ->
    command = 'svn'
    opts ?= {}
    opts.cwd ?= dir()
    stderr ?= (data) -> new StatusView(type: 'alert', message: data.toString())

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
    exit ?= (code) ->
      if code is 0
        new StatusView(type: 'success', message: "Added #{file ? 'all files'}")
    gitCmd
      args: ['add', file ? '.']
      stdout: stdout if stdout?
      stderr: stderr if stderr?
      exit: exit

  checkout:
    console.log 'checkout'

  delete:
    console.log 'delete'

  status:
    console.log 'status'

  update:
    console.log 'update'

  revert:
    console.log 'revert'

  move:
    console.log 'move'

  commit:
    console.log 'commit'

  diff:
    console.log 'diff'
