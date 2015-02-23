"use strict";

var React = require("react");
var RootTmpl = require("./root.rt");

module.exports = React.createClass({
  render: function() {
    return RootTmpl.apply(this);
  }
});
