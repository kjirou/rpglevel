rpglevel [![Build Status](https://travis-ci.org/kjirou/npm-rpglevel.png)](https://travis-ci.org/kjirou/npm-rpglevel)
========

A npm package for creating RPG Level objects.


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
//   Lv1  = 0
//   Lv2  = 4 .. = `return level * 2`
//   Lv3  = 6 .. Total necessary exps are 4 + 6 = 10
//   ..
//   Lv10 = 10
//
lv.defineExpTable(function(level){
  return level * 2;
}, {
  maxLevel: 10
});

lv.gainExp(10);

// Getable your level.
console.log(lv.getLevel());  // -> 3

// Getable more infos.
console.log(lv.getStatuses());
```


## API Reference


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

### For node.js

```
$ grunt node  # Build
$ npm test    # Test
```
