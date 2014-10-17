(function() {
  var ModelTodo, config, _,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  _ = require("lodash");

  config = require("../lib/config");

  ModelTodo = (function(_super) {
    __extends(ModelTodo, _super);

    function ModelTodo() {
      this._postProcessElement = __bind(this._postProcessElement, this);
      this._postProcess = __bind(this._postProcess, this);
      this._return = __bind(this._return, this);
      this._delete = __bind(this._delete, this);
      this._update = __bind(this._update, this);
      this._insert = __bind(this._insert, this);
      this._find = __bind(this._find, this);
      this._get = __bind(this._get, this);
      this.initialize = __bind(this.initialize, this);
      return ModelTodo.__super__.constructor.apply(this, arguments);
    }

    ModelTodo.prototype.name = "todos";

    ModelTodo.prototype.initialize = function() {
      this.get = this._waitUntil(this._get, "connected");
      this.find = this._waitUntil(this._find, "connected");
      this.insert = this._waitUntil(this._insert, "connected");
      this.update = this._waitUntil(this._update, "connected");
      this["delete"] = this._waitUntil(this._delete, "connected");
      this.connect();
    };

    ModelTodo.prototype._get = function(id, cb) {
      this.redis.hget(this._getKey(this.name), this._return);
    };

    ModelTodo.prototype._find = function(cb) {};

    ModelTodo.prototype._insert = function(body, cb) {};

    ModelTodo.prototype._update = function(id, body, cb) {};

    ModelTodo.prototype._delete = function(id, cb) {};

    ModelTodo.prototype._return = function(err, data) {
      if (err) {
        cb(err);
        return;
      }
      cb(null, this._postProcess(data));
    };

    ModelTodo.prototype._postProcess = function(data) {
      var el, _i, _len, _ret;
      if (_.isArray(data)) {
        _ret = [];
        for (_i = 0, _len = data.length; _i < _len; _i++) {
          el = data[_i];
          _ret.push(this._postProcess(el));
        }
        return _ret;
      }
      return this._postProcessElement(data);
    };

    ModelTodo.prototype._postProcessElement = function(data) {
      return JSON.parse(data);
    };

    return ModelTodo;

  })(require("../lib/redisconnector"));

}).call(this);
