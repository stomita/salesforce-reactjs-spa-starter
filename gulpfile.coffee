gulp = require "gulp"
gutil = require "gulp-util"
gulpif = require "gulp-if"
gulpignore = require "gulp-ignore"
plumber = require "gulp-plumber"
changed = require "gulp-changed"
through = require "through2"
glob = require "glob"

rt = require "gulp-react-templates"
rename = require "gulp-rename"

coffee = require "gulp-coffee"
cjsx = require "gulp-cjsx"
babel = require "gulp-babel"

browserify = require "browserify"
espowerify = require "espowerify"
uglify = require "gulp-uglify"
source = require "vinyl-source-stream"
watchify = require "watchify"
notify = require "gulp-notify"
transform = require "vinyl-transform"

less = require "gulp-less"
streamify = require "gulp-streamify"
minify = require "gulp-minify-css"

del = require "del"

zip = require "gulp-zip"
forceDeploy = require "gulp-jsforce-deploy"

mocha = require "gulp-mocha"
karma = require("karma").server;
require "intelli-espower-loader"

express = require "express"
port = 8000

#
paths =
  src:
    app:       "./app"
    test:      "./test"
    assets:    "./app/assets"
    scripts:   "./app/scripts"
    styles:    "./app/styles"
    templates: "./app/templates"
  build:
    app:       "./build/app"
    test:      "./build/test"
    assets:    "./build/app"
    scripts:   "./build/app/scripts"
    styles:    "./build/app/styles"
  lib:         "./bower_components"
  force:       "./src"

#
appName = "MyApp"

#
debug = (gutil.env.type != 'production')


###
# Build Tasks
###

# Copy all static files in src directory to temporary build directory
gulp.task "build:assets", ->
  gulp.src "#{paths.src.assets}/**", base: "#{paths.src.assets}"
    .pipe plumber()
    .pipe changed(paths.build.assets)
    .pipe gulp.dest "#{paths.build.assets}"
    .pipe notify("Assets copied")

# Building CSS files from LESS source
gulp.task "build:styles", ->
  gulp.src "#{paths.src.styles}/main.less"
    .pipe plumber()
    .pipe less()
    .pipe gulp.dest paths.build.styles
    .pipe notify("Style compiled : <%= file.relative %>")
    .pipe gulpignore.exclude(debug) # do not minify if in debug
    .pipe minify()
    .pipe rename(extname: ".min.css")
    .pipe gulp.dest paths.build.styles
    .pipe notify("Minified style created : <%= file.relative %>")

#
compileScript = ->
  gulpif(/\.coffee$/, coffee(bare: true), # Compile CoffeeScript
  gulpif(/\.cjsx$/,   cjsx(bare: true),   # Compile CoffeeScript JSX
  gulpif(/\.jsx?$/,   babel() )))         # Compile ES6 JavaScript (optionally with JSX)

# Compile script files
gulp.task "build:scripts", ->
  gulp.src "#{paths.src.scripts}/**/*.{js,jsx,coffee,cjsx}"
    .pipe plumber()
    .pipe changed(paths.build.scripts, extension: ".js")
    .pipe notify("Compiling : <%= file.relative %>")
    .pipe compileScript()
    .pipe rename(extname: ".js")
    .pipe gulp.dest paths.build.scripts
    .pipe notify("Script compiled : <%= file.relative %>")

# Compile React Template file
gulp.task "build:templates", ->
  gulp.src "#{paths.src.templates}/**/*.rt", base: "#{paths.src.templates}"
    .pipe plumber()
    .pipe changed(paths.build.scripts, extension: ".rt.js")
    .pipe notify("Compiling : <%= file.relative %>")
    .pipe rt(modules: "commonjs")
    .pipe gulp.dest paths.build.scripts
    .pipe notify("Template compiled : <%= file.relative %>")

# build src files
gulp.task "build:src", [ "build:assets", "build:styles", "build:scripts", "build:templates" ]

# Compile test script files
gulp.task "build:test:scripts", ->
  gulp.src "#{paths.src.test}/**/*.{js,jsx,coffee,cjsx}"
    .pipe plumber()
    .pipe changed(paths.build.test, extension: ".js")
    .pipe notify("Compiling : <%= file.relative %>")
    .pipe compileScript()
    .pipe rename(extname: ".js")
    .pipe gulp.dest paths.build.test
    .pipe notify("Script compiled : <%= file.relative %>")

# Build bundle file using browserify
buildBundle = (opts) ->
  { src, dest, watch } = opts
  path = require "path"
  dest = path.dirname(src) unless dest
  bundleName = null
  if path.extname(dest) == ".js"
    bundleName = path.basename(dest)
    dest = path.dirname(dest)
  else
    bundleName = path.basename(src, path.extname(src)) + "-bundle.js"
  bundle = ->
    b = bundler.bundle()
      .on "error", ->
        args = Array.prototype.slice.call(arguments)
        notify.onError(title: "Compile Error", message: "<%= error.message %>").apply(@, args);
        @emit "end"
      .pipe source(bundleName)
      .pipe gulp.dest dest
      .pipe notify("Bundle created : <%= file.relative %>")
      .pipe gulpignore.exclude(debug) # do not minify if in debug
      .pipe streamify uglify()
      .pipe rename(extname: ".min.js")
      .pipe gulp.dest dest
    through.obj (file, enc, callback) ->
      b.on "end", -> callback()
  bundler =
    browserify src,
      transform: [ espowerify ]
      cache: {}
      packageCache: {}
      fullPaths: true
      debug: true
  bundler = watchify(bundler).on "update", bundle if watch
  bundle()

# Bundle files into one runnable script file using browserify
gulp.task "build:bundle", [ "build:src" ], ->
  buildBundle
    src: "#{paths.build.scripts}/main.js"

# Build bundle with watch option
gulp.task "build:bundle:watch", [ "build:src" ], ->
  buildBundle
    src: "#{paths.build.scripts}/main.js"
    watch: true

# All build tasks
gulp.task "build", [ "build:bundle" ]

# Build test scripts
gulp.task "build:test", [ "build:src", "build:test:scripts" ]

# Bundle test scripts for browser testing
gulp.task "build:test:component", [ "build:test" ], (done) ->
  gulp.src "#{paths.build.test}/unit/components/**/*.test.js"
    .pipe transform (filename) ->
      buildBundle
        src: filename

# Build test scripts for browser testing, with watch option
gulp.task "build:test:component:watch", [ "build:test" ], ->
  gulp.src "#{paths.build.test}/unit/components/**/*.test.js"
    .pipe transform (filename) ->
      buildBundle
        src: filename
        watch: true

# All build tasks
gulp.task "build:all", [ "build", "build:test", "build:test:component" ]


# Cleanup built files
gulp.task "clean", ->
  del [ paths.build.app, paths.build.test ]


###
# Archive Tasks
###

# Zip all built files as a static resource file
gulp.task "archive:app", ->
  gulp.src "#{paths.build.app}/**"
    .pipe plumber()
    .pipe zip("#{appName}.resource")
    .pipe gulp.dest "#{paths.force}/staticresources"
    .pipe notify("Zip file created : <%= file.relative %>")

# Zip bower installed libralies
gulp.task "archive:lib", ->
  gulp.src "#{paths.lib}/**"
    .pipe plumber()
    .pipe zip("#{appName}Lib.resource")
    .pipe gulp.dest "#{paths.force}/staticresources"
    .pipe notify("Zip file created : <%= file.relative %>")

# Zip all static resources
gulp.task "archive", [ "archive:lib", "archive:app" ]

# Deploying package to Salesforce
gulp.task "deploy", ->
  gulp.src "#{paths.force}/**/*", base: "."
    .pipe plumber()
    .pipe zip("pkg.zip")
    .pipe forceDeploy
      username: process.env.SF_USERNAME
      password: process.env.SF_PASSWORD
      # loginUrl: "https://test.salesforce.com"
      # pollTimeout: 120*1000
      # pollInterval: 10*1000
      # version: '33.0'


###
# Watch Tasks
###

# 
createOnChangeHandler = (label) ->
  (e) ->
    gutil.log("File #{e.path} was #{e.type}, running '#{label}' task...")

#
gulp.task "watch:common", [ "build:templates", "build:scripts", "build:styles", "build:assets" ], ->
  gulp.watch "#{paths.src.templates}/**", [ "build:templates" ]
    .on "change", createOnChangeHandler("build:templates")
  gulp.watch "#{paths.src.scripts}/**", [ "build:scripts" ]
    .on "change", createOnChangeHandler("build:scripts")
  gulp.watch "#{paths.src.styles}/**", [ "build:styles" ]
    .on "change", createOnChangeHandler("build:styles")
  gulp.watch "#{paths.src.assets}/**", [ "build:assets" ]
    .on "change", createOnChangeHandler("build:assets")

#
gulp.task "watch:test:scripts", [ "build:test:scripts" ], ->
  gulp.watch "#{paths.src.test}/**", [ "build:test:scripts" ]
    .on "change", createOnChangeHandler("test:scripts")

#
gulp.task "watch:build", [ "watch:common", "build:bundle:watch" ]

#
gulp.task "watch:test", [ "watch:common", "watch:test:scripts", "build:test:component:watch" ]

#
gulp.task "watch", [ "watch:build", "watch:test" ]

#
gulp.task "watch:deploy", ->
  gulp.watch "#{paths.build.app}/**", [ "archive:app" ]
  gulp.watch "#{paths.lib}/**", [ "archive:lib" ]
  gulp.watch "#{paths.force}/**", [ "deploy" ]

#
gulp.task "watch:all", [ "watch", "watch:deploy" ]


###
# Test Tasks
###

# Unit test
gulp.task "test:unit", [ "build:test" ], -> gulp.start "test:unit:run"

# Run unit test using mocha (excluding DOM related test)
gulp.task "test:unit:run", ->
  gulp.src [
      "#{paths.build.test}/unit/**/*.test.js"
      "!#{paths.build.test}/unit/components/*.test.js"
    ]
    .pipe plumber()
    .pipe notify("Start Test : <%= file.relative %>")
    .pipe mocha reporter: "spec"
    .pipe notify("Unit Test Completed")

# Unit test with watching update
gulp.task "test:unit:watch", [ "watch:test" ], ->
  gulp.watch [
      "#{paths.build.test}/unit/**/*.test.js"
      "!#{paths.build.test}/unit/components/*.test.js"
    ], [ "test:unit:run" ]
    .on "change", createOnChangeHandler("test:unit:run")
  gulp.start "test:unit:run"


# Component (i.e. DOM related) unit test
gulp.task "test:component", [ "build:test:component" ], -> gulp.start "test:component:run"

# Run component unit test using Karma
gulp.task "test:component:run", (done) ->
  files = glob.sync "#{paths.build.test}/unit/components/**/*.test-bundle.js"
  if files.length > 0
    karma.start
      files: [
        "#{paths.build.test}/unit/components/**/*.test-bundle.js"
      ]
      frameworks: [ "mocha" ]
      reporters: [ "mocha" ]
      browsers: [ "Chrome" ]
      singleRun: true
    , done
  else
    done()

# Component unit test with watching update
gulp.task "test:component:watch", [ "watch:test" ], (done) ->
    karma.start
      files: [
        "#{paths.build.test}/unit/components/**/*.test-bundle.js"
      ]
      frameworks: [ "mocha" ]
      reporters: [ "mocha" ]
      browsers: [ "Chrome" ]
      autoWatch: true
      singleRun: false
    , done

# Start Test
gulp.task "test", [ "test:unit", "test:component" ]

# Test with watch option
gulp.task "test:watch", [ "test:unit:watch", "test:component:watch" ]


###        
# Others
###

# Start HTTP server
gulp.task "serve", [ "build" ], ->
  server = express()
  server.use express.static(paths.build.app)
  server.use express.static(paths.lib)
  server.listen port

#
gulp.task "dev", [ "serve", "watch:build" ]
gulp.task "default", [ "build" ]
