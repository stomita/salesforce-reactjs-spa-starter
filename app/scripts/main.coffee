"use strict"

React = require "react"
Root = require "./components/root"

document.addEventListener "DOMContentLoaded", ->
  React.render React.createElement(Root, {}), document.body