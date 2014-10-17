(function() {
  var RedisHash, crypto, _,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __slice = [].slice;

  _ = require("lodash");

  crypto = require("crypto");

  RedisHash = (function(_super) {
    __extends(RedisHash, _super);

    function RedisHash() {
      this.ERRORS = __bind(this.ERRORS, this);
      this._generateID = __bind(this._generateID, this);
      this._stringifyBody = __bind(this._stringifyBody, this);
      this._postProcessElement = __bind(this._postProcessElement, this);
      this._postProcess = __bind(this._postProcess, this);
      this._return = __bind(this._return, this);
      this._delete = __bind(this._delete, this);
      this._update = __bind(this._update, this);
      this._create = __bind(this._create, this);
      this._list = __bind(this._list, this);
      this._get = __bind(this._get, this);
      this.initialize = __bind(this.initialize, this);
      return RedisHash.__super__.constructor.apply(this, arguments);
    }

    RedisHash.groupname = null;

    RedisHash.prototype.initialize = function() {
      var _ref;
      if (!((_ref = this.groupname) != null ? _ref.length : void 0)) {
        this._handleError(false, "ENOGROUPNAME");
        return;
      }
      this.get = this._waitUntil(this._get, "connected");
      this.list = this._waitUntil(this._list, "connected");
      this.create = this._waitUntil(this._create, "connected");
      this.update = this._waitUntil(this._update, "connected");
      this["delete"] = this._waitUntil(this._delete, "connected");
      this.connect();
    };

    RedisHash.prototype._get = function() {
      var args, cb, options, _i, _id;
      args = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), cb = arguments[_i++];
      _id = args[0], options = args[1];
      if (options == null) {
        options = {};
      }
      this.redis.hget(this._getKey(this.groupname), _id, this._return(cb, true, options));
    };

    RedisHash.prototype._list = function() {
      var args, cb, options, _i;
      args = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), cb = arguments[_i++];
      options = args[0];
      if (options == null) {
        options = {};
      }
      this.debug("list", this._getKey(this.groupname));
      this.redis.hgetall(this._getKey(this.groupname), this._return(cb, options));
    };

    RedisHash.prototype._create = function() {
      var args, body, cb, options, _i, _id, _sBody;
      args = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), cb = arguments[_i++];
      body = args[0], options = args[1];
      if (options == null) {
        options = {};
      }
      _sBody = this._stringifyBody(body, options);
      _id = this._generateID(_sBody);
      this.debug("create", _id, _sBody);
      this.redis.hset(this._getKey(this.groupname), _id, _sBody, this._return(cb, options));
    };

    RedisHash.prototype._update = function() {
      var args, body, cb, options, _i, _id;
      args = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), cb = arguments[_i++];
      _id = args[0], body = args[1], options = args[2];
      if (options == null) {
        options = {};
      }
      this._get(_id, options, (function(_this) {
        return function(err, current) {
          var _sBody;
          if (err) {
            cb(err);
            return;
          }
          if (options.merge) {
            _sBody = _this._stringifyBody(extend(true, {}, current, body), options);
          } else {
            _sBody = _this._stringifyBody(body, options);
          }
          _this.redis.hset(_this._getKey(_this.groupname), _id, _sBody, _this._return(cb, options));
        };
      })(this));
    };

    RedisHash.prototype._delete = function() {
      var args, cb, options, _i, _id;
      args = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), cb = arguments[_i++];
      _id = args[0], options = args[1];
      if (options == null) {
        options = {};
      }
      this._get(_id, options, (function(_this) {
        return function(err, current) {
          if (err) {
            cb(err);
            return;
          }
          _this.redis.hdel(_this._getKey(_this.groupname), _id, _this._return(cb, options));
        };
      })(this));
    };

    RedisHash.prototype._return = function() {
      var args, cb, errorOnEmpty, options, _i;
      cb = arguments[0], args = 3 <= arguments.length ? __slice.call(arguments, 1, _i = arguments.length - 1) : (_i = 1, []), options = arguments[_i++];
      errorOnEmpty = args[0];
      return (function(_this) {
        return function(err, data) {
          if (err) {
            cb(err);
            return;
          }
          if (errorOnEmpty && (data == null)) {
            _this._handleError(cb, "ENOTFOUND");
            return;
          } else if (data == null) {
            data = [];
          }
          cb(null, _this._postProcess(data, options));
        };
      })(this);
    };

    RedisHash.prototype._postProcess = function(data, options) {
      var el, _i, _len, _ret;
      this.debug("_postProcess", data, options);
      if (_.isArray(data)) {
        _ret = [];
        for (_i = 0, _len = data.length; _i < _len; _i++) {
          el = data[_i];
          _ret.push(this._postProcess(el, options));
        }
        return _ret;
      }
      return this._postProcessElement(data, options);
    };

    RedisHash.prototype._postProcessElement = function(data, options) {
      return JSON.parse(data);
    };

    RedisHash.prototype._stringifyBody = function(body, options) {
      if (_.isString(body)) {
        return body;
      } else {
        return JSON.stringify(body);
      }
    };

    RedisHash.prototype._generateID = function(sBody) {
      var ts;
      ts = Date.now();
      return ts;
    };

    RedisHash.prototype.ERRORS = function() {
      return this.extend({}, RedisHash.__super__.ERRORS.apply(this, arguments), {
        "ENOGROUPNAME": [500, "A `this.groupname` key as string is required"],
        "ENOTFOUND": [404, "Element of `" + this.groupname + "` not found"]
      });
    };

    return RedisHash;

  })(require("../lib/redisconnector"));

  module.exports = RedisHash;

}).call(this);
