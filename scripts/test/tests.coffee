if typeof require isnt 'undefined'
  expect = require 'expect.js'
  RPGLevel = require 'RPGLevel'
else
  expect = @expect
  RPGLevel = @RPGLevel


describe('Class Properties ::', ->
    it('VERSION', ->
      expect(RPGLevel.VERSION).to.match(/^\d+\.\d+.\d+(?:\.\d+)?$/)
    )
)


describe('Instance Properties ::', ->
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

      # Use sub data in formula
    )

    it('getExp', ->
      lv = new RPGLevel
      lv._exp = 10
      expect(lv.getExp()).to.be(lv._exp)
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
)
