do () ->

  class RPGLevel

    @VERSION = '1.1.1'

    @DEFAULT_EXP_TABLE_PRESETS =
      wiz_like: [(level, data) ->
        if level is 2
          1000
        else if level in [3..14]
          total = data.previousTotalExp * 1.72414
          parseInt(total - data.previousTotalExp, 10)
        else
          data.exps[13]
      ]

    @InvalidArgsError = class InvalidArgsError extends Error
      constructor: (@message) ->
        @name = 'InvalidArgsError'
        super

    constructor: () ->

      @_exp = 0

      # This is necessary-Exp delta list for Level-Up.
      # For example, [0, 2, 4, 8] means what
      #   it needs total Exps [Lv1=0, Lv2=2, Lv3=6, Lv4=14].
      # For that reason, [0] is always to contain 0.
      @_necessaryExps = []

      @_minLevel = 1

      @_cachedLevelStatuses = null

    _extend: (obj, props) ->
      obj[k] = v for k, v of props
      obj

    @_expTablePresets = {}

    @registerExpTablePreset = (key, args...) ->
      if @_getExpTablePreset(key)
        throw new InvalidArgsError "Already exists Exp-Table key=#{key}"
      @_expTablePresets[key] = args

    @resetExpTablePresets = ->
      @_expTablePresets = {}

    @_getExpTablePreset: (key) ->
      if key of @_expTablePresets
        return @_expTablePresets[key]
      if key of @DEFAULT_EXP_TABLE_PRESETS
        return @DEFAULT_EXP_TABLE_PRESETS[key]
      null

    @_getExpTablePresetOrError: (key) ->
      @_getExpTablePreset(key) ?
        throw new InvalidArgsError "Not found Exp-Table, key=#{key}"

    defineExpTable: (args...) ->
      if typeof args[0] is 'string'
        args = RPGLevel._getExpTablePresetOrError(args[0])

      if args[0] instanceof Array
        @_necessaryExps = args[0]
      else
        @_necessaryExps = @_generateNecessaryExps(args[0], args[1])

      if @_necessaryExps[0] isnt 0
        throw new InvalidArgsError "Invalid Exp-Table."

    _generateNecessaryExps: (formula, options={}) ->
      opts = @_extend(
        startLevel: 1
        maxLevel: 99
      , options)

      exps = []
      previousExp = 0
      previousTotalExp = 0
      memo = {}

      @_necessaryExps = for level in [@_minLevel..opts.maxLevel]

        if level <= opts.startLevel
          exp = 0
        else
          exp = formula(level, {
            self: @
            minLevel: @_minLevel
            startLevel: opts.startLevel
            maxLevel: opts.maxLevel
            levelDelta: opts.maxLevel - opts.startLevel
            exps: exps
            previousExp: previousExp
            previousTotalExp: previousTotalExp
            memo: memo
          })
          previousExp = exp
          previousTotalExp += exp
        exps.push exp
        exp

    getMinLevel: -> @_minLevel

    getMaxLevel: -> @_necessaryExps.length

    getStartLevel: ->
      for i, v of @_necessaryExps
        return parseInt(i, 10) if v > 0

    _getIndexByLevel: (level) ->
      level - 1

    _getLevelByIndex: (index) ->
      parseInt(index, 10) + 1

    getExp: -> @_exp

    getTotalNecessaryExp: (fromLevel, toLevel) ->
      total = 0
      for level in [(fromLevel + 1)..toLevel]
        idx = @_getIndexByLevel(level)
        total += @_necessaryExps[idx]
      total

    getNecessaryExpByLevel: (level) ->
      @_necessaryExps[@_getIndexByLevel(level)]

    getMaxExp: ->
      @getTotalNecessaryExp(@getMinLevel(), @getMaxLevel())

    setExp: (exp) ->
      @_exp = parseInt(exp, 10)
      @_cleanCaches()

    resetExp: () -> @setExp(0)

    _updateExp: (exp) ->
      beforeLevel = @getLevel()

      nextExp = @_exp + exp
      if nextExp > @getMaxExp()
        nextExp = @getMaxExp()
      else if nextExp < 0
        nextExp = 0
      @setExp(nextExp)

      afterLevel = @getLevel()

      return [beforeLevel, afterLevel]

    _createExpUpdateResults: (beforeExp, afterExp, beforeLevel, afterLevel) ->
      {
        beforeExp: beforeExp
        afterExp: afterExp
        expDelta: afterExp - beforeExp
        beforeLevel: beforeLevel
        afterLevel: afterLevel
        levelDelta: afterLevel - beforeLevel
        isLevelUp: afterLevel > beforeLevel
        isLevelDown: afterLevel < beforeLevel
      }

    gainExp: (exp) ->
      beforeExp = @_exp
      [beforeLevel, afterLevel] = @_updateExp(exp)
      @_createExpUpdateResults beforeExp, @_exp, beforeLevel, afterLevel

    drainExp: (exp) ->
      beforeExp = @_exp
      [beforeLevel, afterLevel] = @_updateExp(-exp)
      @_createExpUpdateResults beforeExp, @_exp, beforeLevel, afterLevel

    gainLevel: (levelUpCount) ->
      from = @getLevel()
      to = from + levelUpCount
      to = @getMaxLevel() if to > @getMaxLevel()
      # It is always adjusting like the following:
      #
      #   Lv=1, gainedExpForNext=3 (Remainded 3)
      #     (+1 Level Up)
      #   Lv=2, gainedExpForNext=0 (Always to be 0)
      #
      delta = @getTotalNecessaryExp(@getMinLevel(), to) - @getExp()
      @gainExp(delta)

    drainLevel: (levelDownCount) ->
      to = @getLevel() - levelDownCount
      to = 0 if to < 0
      # It is always adjusting like the following:
      #
      #   Lv=2
      #     (-1 Level down)
      #   Lv=1, necessaryExpForNext=10, gainedExpForNext=9 (Always "necessary - 1")
      #
      delta = @getExp() - @getTotalNecessaryExp(@getMinLevel(), to + 1)
      @drainExp(delta + 1)

    # For mock replacement
    _hasCachedLevelStatuses: ->
        @_cachedLevelStatuses isnt null

    _cleanCaches: -> @_cachedLevelStatuses = null

    getStatuses: ->
      if @_hasCachedLevelStatuses()
        return @_extend({}, @_cachedLevelStatuses)

      myLevel = 0
      totalNecessaryExp = 0
      necessaryExpForNext = 0
      gainedExpForNext = 0

      for idx, exp of @_necessaryExps
        level = @_getLevelByIndex(idx)
        totalNecessaryExp += exp
        if @_exp >= totalNecessaryExp
          myLevel = level
        else
          necessaryExpForNext = exp
          gainedExpForNext = @_exp - (totalNecessaryExp - exp)
          break

      statuses =
        level: myLevel
        necessaryExpForNext: necessaryExpForNext
        gainedExpForNext: gainedExpForNext
        lackExpForNext: necessaryExpForNext - gainedExpForNext

      @_cachedLevelStatuses = @_extend({}, statuses)

      statuses

    getLevel: -> @getStatuses().level

    isMaxLevel: -> @getLevel() is @getMaxLevel()

  rpglevel = RPGLevel: RPGLevel

  # Exports
  if typeof module isnt 'undefined' and module.exports
    module.exports = rpglevel
  if typeof define is 'function' && typeof define.amd is 'object' && define.amd
    define('rpglevel', -> rpglevel)
  if typeof window isnt 'undefined'
    window.rpglevel = rpglevel
