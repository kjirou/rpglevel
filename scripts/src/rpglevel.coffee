do () ->

  # @TODO 定型のExpテーブルを用意
  # @TODO MaxExpを超過した獲得経験値を切り捨てるか保持するかのオプション

  class RPGLevel

    @VERSION = '0.0.1'

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

    defineExpTable: (args...) ->
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

      @_necessaryExps = for level in [@_minLevel..opts.maxLevel]
        if level <= opts.startLevel
          0
        else
          formula(level, {
            minLevel: @_minLevel
            startLevel: opts.startLevel
            maxLevel: opts.maxLevel
          })

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

    getMaxExp: ->
      @getTotalNecessaryExp(@getMinLevel(), @getMaxLevel())

    _updateExp: (exp) ->
      beforeLevel = @getLevel()

      @_exp = @_exp + exp
      if @_exp > @getMaxExp()
        @_exp = @getMaxExp()
      else if @_exp < 0
        @_exp = 0

      @_cachedLevelStatuses = null
      afterLevel = @getLevel()

      return [beforeLevel, afterLevel]

    gainExp: (exp) ->
      [beforeLevel, afterLevel] = @_updateExp(exp)
      afterLevel - beforeLevel

    drainExp: (exp) ->
      [beforeLevel, afterLevel] = @_updateExp(-exp)
      afterLevel - beforeLevel

    # For mock replacement
    _hasCachedLevelStatuses: ->
        @_cachedLevelStatuses isnt null

    getLevelStatuses: ->
      if @_hasCachedLevelStatuses()
        return @_extend({}, @_cachedLevelStatuses)

      myLevel = 0
      totalNecessaryExp = null
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

      # If level is max, then necessaryExpForNext is a null.
      statuses =
        level: myLevel
        necessaryExpForNext: necessaryExpForNext
        gainedExpForNext: gainedExpForNext
        lackExpForNext: necessaryExpForNext - gainedExpForNext

      @_cachedLevelStatuses = @_extend({}, statuses)

      statuses

    getLevel: ->
        @getLevelStatuses().level


  # Exports
  if typeof module isnt 'undefined'
    module.exports = RPGLevel
  else
    window.RPGLevel = RPGLevel


#    /** 現LVから上昇するLV分の経験値を得る
#        余ってた経験値は繰り越される, @return 同gainExp */
#    kls.prototype.gainExpByLv = function(lvCount){
#        var fromLv = this.getLv();
#        var toLv = fromLv + lvCount;
#        toLv = $f.withinNum(toLv, null, this.getLvCap());
#        return this.gainExp(this.calculateTotalNecessaryExp(fromLv, toLv));
#    };
#
#    /** LV計算で経験値を下げる, 端数は切り捨てられてそのLV内での最低値になる */
#    kls.prototype.drainExpByLv = function(lvCount){
#        var toLv = $f.withinNum(this.getLv() - lvCount, 1);
#        this._exp = this.calculateTotalNecessaryExp(1, toLv);
#exp - (1 + 2 + 4)    };
