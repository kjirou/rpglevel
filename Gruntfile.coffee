module.exports = (grunt) ->

  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-mocha-test'
  grunt.loadNpmTasks 'grunt-notify'
  grunt.loadNpmTasks 'grunt-testem'
  grunt.loadNpmTasks 'grunt-text-replace'

  grunt.initConfig

    pkg: grunt.file.readJSON('package.json')

    constants:
      coffee:
        src: [
          'scripts/src/rpglevel.coffee'
        ]
        test: [
          'scripts/test/setup.coffee'
          'scripts/test/tests.coffee'
          'scripts/test/run.coffee'
        ]
      css:
        test: [
          'node_modules/mocha/mocha.css'
        ]
      builded:
        js:
          src: 'test/assets/build/src.js'
          test: 'test/assets/build/test.js'
          node_module: 'build/rpglevel.js'
          node_test: 'build/test.js'
          minified: 'rpglevel.min.js'
          notminified: 'rpglevel.js'
        css:
          all: 'test/assets/build/all.css'

    clean: [
      'test/assets/build'
      'build'
    ]

    coffee:
      options:
        join: true
        bare: false
      development:
        files:
          '<%= constants.builded.js.src %>': [
            '<%= constants.coffee.src %>'
          ]
          '<%= constants.builded.js.test %>': [
            '<%= constants.coffee.test %>'
          ]
      production:
        files:
          '<%= constants.builded.js.notminified %>': [
            '<%= constants.coffee.src %>'
          ]
      development_node:
        files:
          '<%= constants.builded.js.node_module %>': [
            '<%= constants.coffee.src %>'
          ]
          '<%= constants.builded.js.node_test %>': [
            '<%= constants.coffee.test %>'
          ]

    concat:
      development_css:
        options:
          separator: '\n'
        src: [
          '<%= constants.css.test %>'
        ]
        dest: '<%= constants.builded.css.all %>'

    uglify:
      production:
        files:
          '<%= constants.builded.js.minified %>': '<%= constants.builded.js.notminified %>'

    watch:
      main:
        files: [
          '<%= constants.coffee.src %>'
          '<%= constants.coffee.test %>'
        ]
        tasks: ['build']

    testem:
      options:
        launch_in_ci: [
          'PhantomJS'
        ]
      main:
        src: [
          'test/index.html'
        ]
        dest: 'log/tests.tap'
      all_launchers:
        options: {
          launch_in_ci: [
            'PhantomJS'
            'Chrome'
            'Firefox'
            'Safari'
          ]
        }
        src: [
          'test/index.html'
        ]
        dest: 'log/tests.tap'
      travis:
        options: {
          launch_in_ci: [
            'PhantomJS'
          ]
        }
        src: [
          'test/index.html'
        ]

    mochaTest:
      main:
        src: ['<%= constants.builded.js.node_test %>']

    replace:
      version:
        src: [
          'package.json'
          'scripts/src/rpglevel.coffee'
        ]
        overwrite: true
        replacements: [
          from: /(['"])0\.9\.0(['"])/
          to: '$11.0.0$2'
        ]


  # Commands
  grunt.registerTask 'build', [
    'clean:0'
    'coffee:development'
    'concat:development_css'
  ]

  grunt.registerTask 'build:node', [
    'clean:1'
    'coffee:development_node'
  ]

  grunt.registerTask 'test', [
    'build'
    'testem:main'
  ]

  grunt.registerTask 'test:node', [
    'build:node'
    'mochaTest:main'
  ]

  grunt.registerTask 'testall', [
    'build'
    'testem:all_launchers'
  ]

  grunt.registerTask 'travis', [
    'build'
    'testem:travis'
  ]

  grunt.registerTask 'release', [
    'replace:version'
    'coffee:production'
    'uglify:production'
  ]

  grunt.registerTask 'default', ['build']
