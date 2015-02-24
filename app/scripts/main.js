"use strict";

var React = require("react");
var Root = require("./components/root");

document.addEventListener("DOMContentLoaded", function() {
  React.render(React.createElement(Root, {}), document.body);
});
