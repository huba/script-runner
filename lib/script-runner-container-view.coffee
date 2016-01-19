{View, $, $$} = require 'atom-space-pen-views'
ScriptRunnerView = require './script-runner-view'

module.exports =
  class ScriptRunnerContainerView extends View
    initialize: (params) ->
      @orientation = params.orientation
      @addClass(@orientation)
      @runnerViews = []
      @activeViewIndex = null;
    
    @content: ->
      @div class: 'script-runner-container', =>
        @a id: 'toggle-size', click: 'toggleSize', 'minimize'
    
    addRunnerView: (runnerView) ->
      index = @runnerViews.length
      @runnerViews.push runnerView
      @activeViewIndex = index
      runnerView.index = index
      
      @append $$ ->
        @input id: index + '-tab', name: 'tab-select', type: 'radio', checked: false
        @label for: index + '-tab', runnerView.getTitle()
      
      @append runnerView
      
      @activateRunner(index)
      @maximize()
      
      return index
    
    toggleSize: (event) ->
      @toggleClass('minimized')
      
      if @hasClass 'minimized'
        @find('a#toggle-size').html('maximize')
      else
        @find('a#toggle-size').html('minimize')
    
    maximize: ->
      @removeClass('minimized')
      @find('a#toggle-size').html('minimize')
      
    minimize: ->
      @addClass('minimized')
      @find('a#toggle-size').html('maximize')
    
    activateRunner: (index) ->
      @activeViewIndex = index
      console.log @find('input#' + index + '-tab').prop('checked')
      @find('input[type="radio"]:checked').prop('checked', false)
      @find('input[type="radio"]#' + index + '-tab').prop('checked', true)
      console.log @find('input#' + index + '-tab').prop('checked')
    
    activeRunner: ->
      return @runnerViews[@activeViewIndex]
