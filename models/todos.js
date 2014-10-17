(function() {
  var ModelTodo, config, crypto, _,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  _ = require("lodash");

  crypto = require("crypto");

  config = require("../lib/config");

  ModelTodo = (function(_super) {
    __extends(ModelTodo, _super);

    function ModelTodo() {
      return ModelTodo.__super__.constructor.apply(this, arguments);
    }

    ModelTodo.prototype.groupname = "todos";

    return ModelTodo;

  })(require("../redishash"));

  module.exports = new ModelTodo();

}).call(this);
