assert = require "power-assert"

_ = require "lodash"
React = require "react"
Foo = require "../../../app/scripts/components/foo"

#
describe "foo", ->
  it "should create a element", ->
    assert _.isObject(Foo)
    el = React.createElement(Foo, {})
    assert _.isObject(el)
