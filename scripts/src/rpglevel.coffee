do () ->

  class RPGLevel

    @VERSION = '0.0.1'

    constructor: () ->
      @_exp = 0

    getExp: -> @_exp


  # Exports
  if typeof module isnt 'undefined'
    module.exports = RPGLevel
  else
    window.RPGLevel = RPGLevel
