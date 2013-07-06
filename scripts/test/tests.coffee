if typeof require isnt 'undefined'
  expect = require 'expect.js'
  RPGLevel = require 'RPGLevel'
else
  expect = @expect
  RPGLevel = @RPGLevel


describe('RPGLevel Class ::', ->
    it('VERSION', ->
      expect(RPGLevel.VERSION).to.match(/^\d+\.\d+.\d+(?:\.\d+)?$/)
    )
)


describe('RPGLevel Instance ::', ->
    it('Define Exp-Table directly', ->
      lv = new RPGLevel
      lv.defineExpTable([0, 1, 2, 3])
      expect(lv._necessaryExps[2]).to.be(2)
    )

    it('Define invalid Exp-Table directly', ->
      lv = new RPGLevel
      expect(->
        lv.defineExpTable([1, 2, 3])
      ).throwException((e) ->
        expect(e).to.be.a(RPGLevel.InvalidArgsError)
      )
    )

    it('Generate Exp-Table by formula', ->
      lv = new RPGLevel
      lv.defineExpTable((level) -> level * 2)
      expect(lv._necessaryExps[1]).to.be(4)
      expect(lv._necessaryExps[2]).to.be(6)

      # Use options
      lv = new RPGLevel
      lv.defineExpTable(((level) -> level), {
        startLevel: 50
        maxLevel: 55
      })
      expect(lv._necessaryExps[49]).to.be(0)
      expect(lv.getMaxLevel()).to.be(55)

      # Use formula's sub data
      lv = new RPGLevel
      lv.defineExpTable((level, data) ->
        expect(data.minLevel).to.be(1)
        expect(data.startLevel).to.be(2)
        expect(data.maxLevel).to.be(3)
        1
      , {
        startLevel: 2
        maxLevel: 3
      })
    )

    it('getMinLevel', ->
      lv = new RPGLevel
      lv.defineExpTable((level) -> level)
      expect(lv.getMinLevel()).to.be(1)
    )

    it('getMaxLevel', ->
      lv = new RPGLevel
      lv.defineExpTable((level) -> level)
      expect(lv.getMaxLevel()).to.be(99)

      lv = new RPGLevel
      lv.defineExpTable(((level) -> level), maxLevel: 10)
      expect(lv.getMaxLevel()).to.be(10)
    )

    it('getStartLevel', ->
      lv = new RPGLevel
      lv.defineExpTable((level) -> level)
      expect(lv.getStartLevel()).to.be(1)

      lv = new RPGLevel
      lv.defineExpTable(((level) -> level), startLevel: 5)
      expect(lv.getStartLevel()).to.be(5)
    )

    it('getTotalNecessaryExp / getMaxExp', ->
      lv = new RPGLevel
      lv.defineExpTable([0, 1, 2, 4, 8, 16])
      expect(lv.getTotalNecessaryExp(2, 4)).to.be(2 + 4)
      expect(lv.getMaxExp()).to.be(1 + 2 + 4 + 8 + 16)
    )

    it('gainExp / getExp', ->
      lv = new RPGLevel
      lv.defineExpTable((level) -> level)
      exp = 100
      lv.gainExp(exp)
      expect(lv.getExp()).to.be(exp)
    )

    it('getLevelStatuses', ->
      lv = new RPGLevel
      lv.defineExpTable([0, 1, 2, 4, 8, 16, 32])
      exp = 8
      lv.gainExp(exp)
      stats = lv.getLevelStatuses()

      expect(stats).to.be.a('object')
      expect(stats.level).to.be(4)
      expect(stats.necessaryExpForNext).to.be(8)
      expect(stats.gainedExpForNext).to.be(exp - (1 + 2 + 4))
      expect(stats.lackExpForNext).to.be(8 - stats.gainedExpForNext)
    )
)


describe('Cache computations ::', ->
)
