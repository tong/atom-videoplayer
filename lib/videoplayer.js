(function (console, $hx_exports) { "use strict";
var HxOverrides = function() { };
HxOverrides.substr = function(s,pos,len) {
	if(pos != null && pos != 0 && len != null && len < 0) return "";
	if(len == null) len = s.length;
	if(pos < 0) {
		pos = s.length + pos;
		if(pos < 0) pos = 0;
	} else if(len < 0) len = s.length + len - pos;
	return s.substr(pos,len);
};
HxOverrides.iter = function(a) {
	return { cur : 0, arr : a, hasNext : function() {
		return this.cur < this.arr.length;
	}, next : function() {
		return this.arr[this.cur++];
	}};
};
var Lambda = function() { };
Lambda.has = function(it,elt) {
	var $it0 = $iterator(it)();
	while( $it0.hasNext() ) {
		var x = $it0.next();
		if(x == elt) return true;
	}
	return false;
};
var VideoPlayer = $hx_exports.VideoPlayer = function(path) {
	this.seekFastFactor = 10;
	this.seekFactor = 30;
	this.path = path;
	this.tabTitle = haxe_io_Path.withoutDirectory(path);
	this.isPlaying = false;
	this.subscriptions = new atom_CompositeDisposable();
};
VideoPlayer.prototype = {
	initialize: function(view) {
		this.view = view;
		view.addEventListener("focus",$bind(this,this.handleFocus),false);
		view.addEventListener("blur",$bind(this,this.handleBlur),false);
		view.addEventListener("ended",$bind(this,this.handleVideoEnd),false);
		if(atom.config.get("videoplayer.autoplay")) this.play();
	}
	,destroy: function() {
		this.subscriptions.dispose();
		this.pause();
		this.view.removeEventListener("focus",$bind(this,this.handleFocus));
		this.view.removeEventListener("blur",$bind(this,this.handleBlur));
		this.view.removeEventListener("ended",$bind(this,this.handleVideoEnd));
		var this1 = this.view;
		this1.pause();
		this1.remove();
		this1.src = null;
	}
	,getTitle: function() {
		return this.tabTitle;
	}
	,play: function() {
		if(this.view != null && !this.isPlaying) {
			this.isPlaying = true;
			this.view.play();
		}
	}
	,pause: function() {
		if(this.view != null && this.isPlaying) {
			this.isPlaying = false;
			this.view.pause();
		}
	}
	,togglePlayback: function() {
		if(this.isPlaying) this.pause(); else this.play();
	}
	,addCommand: function(id,fun) {
		this.subscriptions.add(atom.commands.add("atom-workspace","videoplayer:" + id,function(_) {
			fun();
		}));
	}
	,handleFocus: function(e) {
		var _g = this;
		this.addCommand("toggle-playback",$bind(this,this.togglePlayback));
		this.addCommand("seek-forward",function() {
			var this1 = _g.view;
			this1.currentTime = this1.currentTime + _g.view.duration / _g.seekFactor;
		});
		this.addCommand("seek-backward",function() {
			var this2 = _g.view;
			this2.currentTime = this2.currentTime + -_g.view.duration / _g.seekFactor;
		});
		this.addCommand("seek-forward-fast",function() {
			var this3 = _g.view;
			this3.currentTime = this3.currentTime + _g.view.duration / _g.seekFastFactor;
		});
		this.addCommand("seek-backward-fast",function() {
			var this4 = _g.view;
			this4.currentTime = this4.currentTime + -_g.view.duration / _g.seekFastFactor;
		});
		this.addCommand("goto-start",function() {
			_g.view.currentTime = 0;
		});
		this.addCommand("goto-end",function() {
			_g.view.currentTime = _g.view.duration;
		});
	}
	,handleBlur: function(e) {
		this.subscriptions.dispose();
	}
	,handleVideoEnd: function(e) {
		this.isPlaying = false;
	}
};
var VideoPlayerPackage = $hx_exports.VideoPlayerPackage = function() { };
VideoPlayerPackage.activate = function(state) {
	VideoPlayerPackage.viewProvider = atom.views.addViewProvider({ modelConstructor : VideoPlayer, createView : function(player) {
		var view;
		var volume = atom.config.get("videoplayer.volume");
		var this1;
		var _this = window.document;
		this1 = _this.createElement("video");
		this1.classList.add("videoplayer");
		this1.controls = true;
		this1.volume = volume;
		this1.src = "file://" + player.path;
		view = this1;
		player.initialize(view);
		return view;
	}});
	VideoPlayerPackage.opener = atom.workspace.addOpener(function(path) {
		if(Lambda.has(VideoPlayerPackage.allowedFileTypes,haxe_io_Path.extension(path))) return new VideoPlayer(path); else return null;
	});
};
VideoPlayerPackage.deactivate = function() {
	VideoPlayerPackage.viewProvider.dispose();
	VideoPlayerPackage.opener.dispose();
};
var atom_CompositeDisposable = require("atom").CompositeDisposable;
var haxe_io_Path = function(path) {
	switch(path) {
	case ".":case "..":
		this.dir = path;
		this.file = "";
		return;
	}
	var c1 = path.lastIndexOf("/");
	var c2 = path.lastIndexOf("\\");
	if(c1 < c2) {
		this.dir = HxOverrides.substr(path,0,c2);
		path = HxOverrides.substr(path,c2 + 1,null);
		this.backslash = true;
	} else if(c2 < c1) {
		this.dir = HxOverrides.substr(path,0,c1);
		path = HxOverrides.substr(path,c1 + 1,null);
	} else this.dir = null;
	var cp = path.lastIndexOf(".");
	if(cp != -1) {
		this.ext = HxOverrides.substr(path,cp + 1,null);
		this.file = HxOverrides.substr(path,0,cp);
	} else {
		this.ext = null;
		this.file = path;
	}
};
haxe_io_Path.withoutDirectory = function(path) {
	var s = new haxe_io_Path(path);
	s.dir = null;
	return s.toString();
};
haxe_io_Path.extension = function(path) {
	var s = new haxe_io_Path(path);
	if(s.ext == null) return "";
	return s.ext;
};
haxe_io_Path.prototype = {
	toString: function() {
		return (this.dir == null?"":this.dir + (this.backslash?"\\":"/")) + this.file + (this.ext == null?"":"." + this.ext);
	}
};
function $iterator(o) { if( o instanceof Array ) return function() { return HxOverrides.iter(o); }; return typeof(o.iterator) == 'function' ? $bind(o,o.iterator) : o.iterator; }
var $_, $fid = 0;
function $bind(o,m) { if( m == null ) return null; if( m.__id__ == null ) m.__id__ = $fid++; var f; if( o.hx__closures__ == null ) o.hx__closures__ = {}; else f = o.hx__closures__[m.__id__]; if( f == null ) { f = function(){ return f.method.apply(f.scope, arguments); }; f.scope = o; f.method = m; o.hx__closures__[m.__id__] = f; } return f; }
module.exports = VideoPlayerPackage;
VideoPlayerPackage.allowedFileTypes = ["3gp","avi","mov","mp4","m4v","mkv","ogv","ogm","webm"];
VideoPlayerPackage.config = { autoplay : { 'title' : "Autoplay", 'type' : "boolean", 'default' : true}, volume : { 'title' : "Default Volume", 'type' : "number", 'default' : 0.7, 'minimum' : 0.0, 'maximum' : 1.0}};
})(typeof console != "undefined" ? console : {log:function(){}}, typeof window != "undefined" ? window : exports);
