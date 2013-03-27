module.exports = (grunt) ->
  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-contrib-concat"
  grunt.loadNpmTasks "grunt-contrib-stylus"
  grunt.loadNpmTasks "grunt-contrib-jade"
  grunt.loadNpmTasks "grunt-contrib-copy"
  grunt.loadNpmTasks "grunt-contrib-clean"
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-contrib-connect"

  grunt.initConfig
    coffee:
      "build/js/app.js": ["app/app.coffee", "app/**/*.coffee"]

    concat:
      js:
        dest: "build/js/vendor.js"
        src: [
          "vendor/jquery-1.8.3.js"
          "vendor/underscore.js"
          "vendor/backbone.js",
          "vendor/*.js"
        ]
      css:
        dest: "build/css/app.css"
        src: [
          "vendor/*.css"
          "tmp/import.css"
        ]

    stylus:
      compile:
        options:
          use: [require "nib"]
        files:
          "tmp/import.css": ["app/styles/import.styl"]

    jade:
      files:
        expand: true
        cwd: "app"
        src: ["**/*.jade"]
        ext: ".html"
        dest: "build"

    copy:
      assets:
        files: [
          expand: true
          src: ["app/assets/**"]
          dest: "build/"
          rename: (dest, src) ->
            dest + src.slice "app/assets/".length
        ]
      public:
        files: [
          expand: true
          src: ["build/**"]
          dest: "_public/"
          rename: (dest, src) ->
            dest + src.slice "build/".length
        ]

    clean: ["tmp"]
    watch:
      js:
        files: ["app/**/*.coffee"]
        tasks: ["coffee", "concat:js"]
        options: interrupt: true
      css:
        files: ["app/**/*.styl"]
        tasks: ["stylus", "concat:css", "clean"]
        options: interrupt: true
      jade:
        files: ["app/**/*.jade"]
        tasks: ["jade"]
        options: interrupt: true

    connect:
      server:
        options:
          port:      4040
          base:      "build"
          keepalive: true

  grunt.registerTask "build", "Build files to build/", [
    "copy:assets"
    "coffee"
    "stylus"
    "jade"
    "concat"
    "clean"
  ]

  grunt.registerTask "deploy", "Build and copy to _public/",
    ["build", "copy:public"]

  spawn = (options, done = ->) ->
    options.opts ?= stdio: "inherit"
    grunt.util.spawn options, done

  grunt.registerTask "test", "Run testacular for unit tests", ->
    @async()

    spawn
      cmd: "./node_modules/.bin/testacular"
      args: ["start", "test/testacular.conf.js"]

  grunt.registerTask "run", "Watch app/ and run test server", ->
    @async()

    grunt.util.spawn
      grunt: true
      args: ["build"]
    , ->
      spawn
        grunt: true
        args: ["watch"]

      spawn
        grunt: true
        args: ["server"]

  grunt.registerTask "go", "Runs watch, server, and test", ->
    @async()

    grunt.util.spawn
      grunt: true
      args: ["build"]
    , ->
      spawn
        grunt: true
        args: ["watch"]

      spawn
        grunt: true
        args: ["server"]

      spawn
        grunt: true
        args: ["test"]

  grunt.registerTask "server", "Run test server", ["connect"]

