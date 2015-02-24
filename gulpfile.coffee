gulp = require "gulp"
gutil = require "gulp-util"
gulpif = require "gulp-if"
plumber = require "gulp-plumber"
changed = require "gulp-changed"

rt = require "gulp-react-templates"
rename = require "gulp-rename"

coffee = require "gulp-coffee"
cjsx = require "gulp-cjsx"
babel = require "gulp-babel"

browserify = require "browserify"
uglify = require "gulp-uglify"
source = require "vinyl-source-stream"
watchify = require "watchify"
notify = require "gulp-notify"

less = require "gulp-less"
streamify = require "gulp-streamify"
minify = require "gulp-minify-css"

del = require "del"

zip = require "gulp-zip"
forceDeploy = require "gulp-jsforce-deploy"

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
# Tasks
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
    .pipe minify()
    .pipe rename(extname: ".min.css")
    .pipe gulp.dest paths.build.styles
    .pipe notify("Style compiled : <%= file.relative %>")

# Build script files
gulp.task "build:scripts", ->
  gulp.src "#{paths.src.scripts}/**/*.{js,jsx,coffee,cjsx}"
    .pipe plumber()
    .pipe changed(paths.build.scripts, extension: ".js")
    .pipe gulpif(/\.coffee$/, coffee(bare: true), # Compile CoffeeScript
          gulpif(/\.cjsx$/,   cjsx(bare: true),   # Compile CoffeeScript JSX
          gulpif(/\.jsx?$/,   babel() )))         # Compile ES6 JavaScript (optionally with JSX)
    .pipe rename(extname: ".js")
    .pipe gulp.dest paths.build.scripts
    .pipe notify("Script compiled : <%= file.relative %>")

# Compile React Template file
gulp.task "build:templates", ->
  gulp.src "#{paths.src.templates}/**/*.rt", base: "#{paths.src.templates}"
    .pipe plumber()
    .pipe changed(paths.build.scripts, extension: ".rt.js")
    .pipe rt(modules: "commonjs")
    .pipe gulp.dest paths.build.scripts
    .pipe notify("Template compiled : <%= file.relative %>")

#
buildBundle = (opts) ->
  { src, dest, watching } = opts
  p = require "path"
  bundleName = p.basename(src, p.extname(src)) + "-bundle.js"
  console.log bundleName
  bundle = ->
    bundler
      .bundle()
      .on "error", ->
        args = Array.prototype.slice.call(arguments)
        notify.onError(title: "Compile Error", message: "<%= error.message %>").apply(@, args);
        @emit "end"
      .pipe source(bundleName)
      .pipe gulp.dest paths.build.scripts
      .pipe notify("Bundle created : <%= file.relative %>")
      .pipe streamify uglify()
      .pipe rename(extname: ".min.js")
      .pipe gulp.dest dest
      .pipe notify("Bundle created : <%= file.relative %>")
  bundler =
    browserify src,
      cache: {}
      packageCache: {}
      fullPaths: true
      debug: true
  bundler = watchify(bundler).on "update", bundle if watching
  bundle()

# Bundle files into one runnable script file using browserify
gulp.task "build:bundle", ->
  buildBundle
    src: "#{paths.build.scripts}/main.js"
    dest: paths.build.scripts

# Build bundle with watch option
gulp.task "build:bundleWatch", ->
  buildBundle 
    src: "#{paths.build.scripts}/main.js"
    dest: paths.build.scripts
    watching: true

# All build tasks
gulp.task "build", [ "build:assets", "build:styles", "build:scripts", "build:templates",  "build:bundle" ]

# Build test scripts
gulp.task "build:testBundle", ->
  buildBundle
    src: "#{paths.build.test}/**/test.js"
    dest: paths.build.test

# Build test scripts
gulp.task "build:testBundleWatch", ->
  buildBundle
    src: "#{paths.build.test}/**/test.js"
    dest: paths.build.test

# Build test scripts
gulp.task "build:testAll", [ "build:assets", "build:styles", "build:scripts", "build:template", "build:test", "build:testBundle" ]

# Cleanup built files
gulp.task "clean", ->
  del [ paths.build.app, paths.build.test ]

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

#
createOnChangeHandler = (label) ->
  (e) ->
    console.log("File #{e.path} was #{e.type}, running 'build:#{label}' task...")

#
gulp.task "watch:common", [ "build:templates", "build:scripts", "build:styles", "build:assets" ], ->
  gulp.watch "#{paths.src.templates}/**", [ "build:templates" ]
    .on "change", createOnChangeHandler("templates")
  gulp.watch "#{paths.src.scripts}/**", [ "build:scripts" ]
    .on "change", createOnChangeHandler("scripts")
  gulp.watch "#{paths.src.styles}/**", [ "build:styles" ]
    .on "change", createOnChangeHandler("styles")
  gulp.watch "#{paths.src.assets}/**", [ "build:assets" ]
    .on "change", createOnChangeHandler("assets")

#
gulp.task "watch:test", [ "build:test" ], ->
  gulp.watch "#{paths.src.test}/**", [ "build:test" ]
    .on "change", createOnChangeHandler("test")

#
gulp.task "watch:build", [ "watch:common", "build:bundleWatch" ]

#
gulp.task "watch:test", [ "watch:common", "watch:test", "build:testBundleWatch" ]

#
gulp.task "watch:deploy", ->
  gulp.watch "#{paths.build.app}/**", [ "archive:app" ]
  gulp.watch "#{paths.lib}/**", [ "archive:lib" ]
  gulp.watch "#{paths.force}/**", [ "deploy" ]

#
gulp.task "watch", [ "watch:build", "watch:deploy" ]


# Start HTTP server
gulp.task "serve", [ "build" ], ->
  server = express()
  server.use express.static(paths.build.app)
  server.use express.static(paths.lib)
  server.listen port

#
gulp.task "dev", [ "serve", "watch:build" ]
gulp.task "default", [ "build" ]
