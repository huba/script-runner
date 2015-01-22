ChildProcess = require('child_process')
Path = require('path')
Shellwords = require('shellwords')

module.exports =
class ScriptRunnerProcess
  constructor: ->
    @_view = atom.views.getView(this)
    @child = null
  
  stop: (signal = 'SIGINT') ->
    if @child
      console.log("Sending", signal, "to child", @child, "pid", @child.pid)
      process.kill(-@child.pid, signal)
      if @_view
        @_view.append('<Sending ' + signal + '>', 'stdin')
  
  execute: (cmd, env, editor) ->
    @_view.clear()
    @_view.setTitle(editor.getTitle())
    
    cwd = atom.project.path

    # Save the file if it has been modified:
    if editor.getPath()
      editor.save()
      cwd = Path.dirname(editor.getPath())
    
    # If the editor refers to a buffer on disk which has not been modified, we can use it directly:
    if editor.getPath() and !editor.buffer.isModified()
      cmd = cmd + ' ' + editor.getPath()
      appendBuffer = false
    else
      appendBuffer = true
    
    # PTY emulation wrapper:
    args = Shellwords.split(cmd)
    args.unshift(__dirname + "/script-wrapper.py")
    
    # Spawn the child process:
    @child = ChildProcess.spawn(args[0], args.slice(1), cwd: cwd, env: env, detached: true)
    
    @_view.header('Running: ' + cmd + ' (pgid ' + @child.pid + ')')
    
    # Handle various events relating to the child process:
    @child.stderr.on 'data', (data) =>
      if @_view?
        @_view.append(data, 'stderr')
        @_view.scrollToBottom()
    
    @child.stdout.on 'data', (data) =>
      if @_view?
        @_view.append(data, 'stdout')
        @_view.scrollToBottom()
    
    @child.on 'close', (code, signal) =>
      #console.log("process", args, "exit", code, signal)
      @child = null
      if @_view
        duration = ' after ' + ((new Date - startTime) / 1000) + ' seconds'
        if signal
          @_view.footer('Exited with signal ' + signal + duration)
        else
          # Sometimes code seems to be null too, not sure why, perhaps a bug in node.
          code ||= 0
          @_view.footer('Exited with status ' + code + duration)
    
    startTime = new Date
    
    # Could not supply file name:
    if appendBuffer
      @child.stdin.write(editor.getText())
    
    @child.stdin.end()
