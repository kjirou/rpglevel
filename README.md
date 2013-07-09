rpglevel [![Build Status](https://travis-ci.org/kjirou/npm-rpglevel.png)](https://travis-ci.org/kjirou/npm-rpglevel)
========

A npm package for creating RPG Level objects.


## Download

- [Stable production version](https://raw.github.com/kjirou/npm-rpglevel/master/rpglevel.min.js)
- [Stable development version](https://raw.github.com/kjirou/npm-rpglevel/master/rpglevel.js)
- [Old releases](https://github.com/kjirou/npm-rpglevel/releases)

Or, if you can use `node.js`:
```
$ npm install rpglevel
```


## Supported browsers/node.js

- `IE10`, `IE9`, `IE8`, `IE7`
- `Chrome`
- `Firefox`
- `Safari`
- `Mobile Safari`
- `PhantomJS`
- `node.js` >= `11.0`


## Usage
```
var lv = new RPGLevel();

//
// Define Exp-Table by formula.
//
//   Lv1 = 0
//   Lv2 = 4
//   Lv3 = 6  (Total = 10)
//   Lv4 = 8  (Total = 18)
//   Lv5 = 10 (Total = 28)
//
lv.defineExpTable(function(level){
  return level * 2;
}, {
  maxLevel: 5
});

// You got exps with 2 levels up.
lv.gainExp(10);

// Getable your level.
console.log(lv.getLevel());  // -> 3

// Getable more infos.
console.log(lv.getStatuses());  // -> { level:3, .. }
```


## API Reference

### RPGLevel Class

- `new RPGLevel()`
- `VERSION = "X.X.X"`

### RPGLevel Instance

- `defineExpTable(necessaryExps)`
- `defineExpTable(formula, options={})`
- `defineExpTable(definitionKey)`
- `getMinLevel()`
- `getMaxLevel()`
- `getStartLevel()`
- `getExp()`
- `getTotalNecessaryExp(fromLevel, toLevel)`
- `getNecessaryExpByLevel(level)`
- `getMaxExp()`
- `setExp(exp)`
- `resetExp()`
- `gainExp(exp)`
- `drainExp(exp)`
- `gainLevel(levelUpCount)`
- `drainLevel(levelDownCount)`
- `getStatuses()`
- `getLevel()`
- `isMaxLevel()`

Sorry, these are not enough. Please look a [source code](https://github.com/kjirou/npm-rpglevel/blob/master/scripts/src/rpglevel.coffee).


## Development

### Dependencies

- `node.js` >= `11.0`, e.g. `brew install node`
- `PhantomJS`, e.g. `brew install phantomjs`

```
$ npm install -g grunt-cli testem
```

### Deploy

```
$ git clone git@github.com:kjirou/npm-rpglevel.git
$ cd npm-rpglevel
$ npm install
$ grunt
```

### Build commands

- `grunt` builds all files for development by browser.
- `grunt watch` executes `grunt` each time at updating CoffeeScript files.
- `grunt release` generates JavaScript files for release.

### Testing

- Open [test/index.html](test/index.html)
- Execute `testem` or `testem server`, after that, open [http://localhost:7357/](http://localhost:7357/)
- `grunt test` is CI test by PhantomJS only.
- `grunt testall` is CI test by PhantomJS, Chrome, Firefox and Safari.
- `npm test` tests by node.js.
