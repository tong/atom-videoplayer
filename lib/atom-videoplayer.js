(function (console) { "use strict";
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
var Main = function() { };
Main.activate = function(state) {
	console.log("Atom-videoplayer");
	Main.viewProvider = atom.views.addViewProvider(VideoPlayer,function(player) {
		var view = new VideoPlayerView();
		player.initialize(view);
		return view.dom;
	});
	Main.opener = atom.workspace.addOpener(function(path) {
		var ext = haxe_io_Path.extension(path).toLowerCase();
		if(Lambda.has(Main.allowedFileTypes,ext)) {
			var player1 = new VideoPlayer(path);
			player1.onReady = function() {
			};
			return player1;
		}
		return null;
	});
};
Main.deactivate = function() {
	Main.viewProvider.dispose();
	Main.opener.dispose();
};
Main.consumeStatusBar = function(bar) {
};
var VideoPlayer = function(path) {
	this.path = path;
	this.seekSpeed = atom.config.get("videoplayer.seek_speed");
	this.wheelSpeed = atom.config.get("videoplayer.wheel_speed");
	this.isReady = this.isPlaying = false;
	this.subscriptions = new atom_CompositeDisposable();
};
VideoPlayer.prototype = {
	onReady: function() {
	}
	,get_width: function() {
		if(this.isReady) return this.view.video.videoWidth; else return null;
	}
	,get_height: function() {
		if(this.isReady) return this.view.video.videoHeight; else return null;
	}
	,initialize: function(view) {
		this.view = view;
		view.video.src = "file://" + this.path;
		view.video.autoplay = atom.config.get("videoplayer.autoplay");
		view.video.volume = atom.config.get("videoplayer.volume");
		view.video.loop = atom.config.get("videoplayer.loop");
		view.video.controls = true;
		view.video.addEventListener("canplaythrough",$bind(this,this.handleCanPlay),false);
		view.dom.addEventListener("focus",$bind(this,this.handleFocus),false);
		view.dom.addEventListener("blur",$bind(this,this.handleBlur),false);
		view.dom.addEventListener("click",$bind(this,this.handleClick),false);
		view.dom.addEventListener("mousewheel",$bind(this,this.handleMouseWheel),false);
	}
	,destroy: function() {
		this.subscriptions.dispose();
		this.view.destroy();
		this.view.video.removeEventListener("canplaythrough",$bind(this,this.handleCanPlay));
		this.view.dom.removeEventListener("focus",$bind(this,this.handleBlur));
		this.view.dom.removeEventListener("blur",$bind(this,this.handleBlur));
		this.view.dom.removeEventListener("click",$bind(this,this.handleClick));
		this.view.dom.removeEventListener("mousewheel",$bind(this,this.handleMouseWheel));
	}
	,getTitle: function() {
		return haxe_io_Path.withoutDirectory(this.path);
	}
	,getLongTitle: function() {
		return haxe_io_Path.withoutDirectory(this.path);
	}
	,getIconName: function() {
		return "file-media";
	}
	,getPath: function() {
		return this.path;
	}
	,play: function() {
		if(this.view != null && !this.isPlaying) {
			this.isPlaying = true;
			this.view.video.play();
		}
	}
	,pause: function() {
		if(this.view != null && this.isPlaying) {
			this.isPlaying = false;
			this.view.video.pause();
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
	,handleCanPlay: function(e) {
		if(!this.isReady) {
			this.isReady = true;
			if(this.view.video.autoplay) this.isPlaying = true;
			this.onReady();
		}
	}
	,handleVideoEnd: function(e) {
		this.isPlaying = false;
	}
	,handleClick: function(e) {
		this.togglePlayback();
	}
	,handleMouseWheel: function(e) {
		var v = e.wheelDelta / 100 * this.wheelSpeed;
		if(e.ctrlKey) v *= 10;
		this.view.seek(v);
	}
	,handleFocus: function(e) {
		var _g = this;
		this.addCommand("toggle-playback",$bind(this,this.togglePlayback));
		this.addCommand("seek-forward",function() {
			_g.view.seek(_g.view.video.duration / 10 * _g.seekSpeed);
		});
		this.addCommand("seek-backward",function() {
			_g.view.seek(-(_g.view.video.duration / 10 * _g.seekSpeed));
		});
		this.addCommand("goto-start",function() {
			_g.view.video.currentTime = 0;
		});
		this.addCommand("goto-end",function() {
			_g.view.video.currentTime = _g.view.video.duration;
		});
		this.addCommand("mute",function() {
			_g.view.video.muted = !_g.view.video.muted;
		});
	}
	,handleBlur: function(e) {
		this.subscriptions.dispose();
	}
};
var VideoPlayerView = function() {
	var _this = window.document;
	this.dom = _this.createElement("div");
	this.dom.classList.add("videoplayer");
	this.dom.setAttribute("tabindex","-1");
	var _this1 = window.document;
	this.video = _this1.createElement("video");
	this.dom.appendChild(this.video);
	var _this2 = window.document;
	this.info = _this2.createElement("div");
	this.info.classList.add("info");
	this.dom.appendChild(this.info);
};
VideoPlayerView.prototype = {
	destroy: function() {
	}
	,seek: function(time) {
		if(this.video.currentTime != null) this.video.currentTime += time;
	}
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
module.exports = Main;
Main.allowedFileTypes = ["3gp","avi","mov","mp4","m4v","mkv","ogv","ogm","webm"];
Main.config = { autoplay : { 'title' : "Autoplay", 'type' : "boolean", 'default' : true}, loop : { 'title' : "Loop video", 'type' : "boolean", 'default' : false}, seek_speed : { 'title' : "Seek speed keyboard", 'type' : "number", 'default' : 0.5, 'minimum' : 0.0, 'maximum' : 1.0}, wheel_speed : { 'title' : "Seek speed mousewheel", 'type' : "number", 'default' : 0.5, 'minimum' : 0.0, 'maximum' : 1.0}, volume : { 'title' : "Default Volume", 'type' : "number", 'default' : 0.7, 'minimum' : 0.0, 'maximum' : 1.0}};
})(typeof console != "undefined" ? console : {log:function(){}});
