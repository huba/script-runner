{ScrollView} = require 'atom-space-pen-views'
Convert = require('ansi-to-html')

module.exports =
class ScriptRunnerView extends ScrollView
  atom.deserializers.add(this)
  
  @viewFactory: ->
    return new ScriptRunnerView()

  @deserialize: ({title, header, output, footer}) ->
    view = new ScriptRunnerView()
    view._header.html(header)
    view._output.html(output)
    view._footer.html(footer)
    view.setTitle(title)
    return view

  @content: ->
    @div class: 'script-runner', tabindex: -1, =>
      @h1 'Script Runner'
      @div class: 'header'
      @pre class: 'output'
      @div class: 'footer'

  initialize: ->
    # super
    atom.commands.add this, "run:copy": (event) => @copyToClipboard()
    
    @convert = new Convert({escapeXML: true})
    @_header = @find('.header')
    @_output = @find('.output')
    @_footer = @find('.footer')

  serialize: ->
    deserializer: 'ScriptRunnerView'
    title: @title
    header: @_header.html()
    output: @_output.html()
    footer: @_footer.html()

  copyToClipboard: ->
    atom.clipboard.write(window.getSelection().toString())
  
  getTitle: ->
    return "Script Runner: #{@title}"
  
  setTitle: (title) ->
    #TODO: Somehow force the tab title to update too.
    @title = title
    @find('h1').html(@getTitle())

  clear: ->
    @_output.html('')
    @_header.html('')
    @_footer.html('')

  append: (text, className) ->
    span = document.createElement('span')
    span.innerHTML = @convert.toHtml([text])
    span.className = className || 'stdout'
    @_output.append(span)

  header: (text) ->
    @_header.html(text)

  footer: (text) ->
    @_footer.html(text)
