"use strict";

React = require "react"
AppBodyTmpl = require "./app-body.rt"

module.exports = React.createClass
  render: ->
    AppBodyTmpl.apply(@)
