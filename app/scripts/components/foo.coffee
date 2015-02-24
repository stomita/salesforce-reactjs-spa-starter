"use strict"

React = require "react"
FooTmpl = require "./foo.rt"

sayHello = require "../util/say-hello"

module.exports = React.createClass
  onClick: ->
    window.alert sayHello(@props.children)

  render: ->
    FooTmpl.apply(@)
