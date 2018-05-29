
import js.Browser.document;
import js.Node.console;
import js.html.DivElement;
import js.html.VideoElement;
import js.node.Fs;
import atom.CompositeDisposable;
import atom.Disposable;
import atom.File;
import Atom.config;
import Atom.workspace;

using Lambda;
using StringTools;
using haxe.io.Path;

private enum ScaleMode {
	Fit;
	Letterbox;
	Original;
}

private abstract Statusbar(DivElement) to DivElement {

	public var text(get,set) : String;
	inline function get_text() return this.textContent;
	inline function set_text(s:String) return this.textContent = s;

	public inline function new() {
		this = document.createDivElement();
		this.classList.add( 'status-bar-videoplayer', 'inline-block', 'icon', 'file-media'  );
		hide();
	}

	public inline function show() {
		this.style.display = 'inline-block';
	}

	public inline function hide() {
		this.style.display = 'none';
	}

	public inline function dispose() {
		this.remove();
	}
}

@:keep
@:expose
class VideoPlayer {

    static inline function __init__() untyped module.exports = VideoPlayer;

	static var allowedFileTypes = ['3gp','avi','mov','mp4','m4v','mkv','ogv','ogm','webm'];
    static var disposables : CompositeDisposable;
    static var statusbar : Statusbar;

    static function activate( state : Dynamic ) {
        disposables = new CompositeDisposable();
		disposables.add( workspace.addOpener( openURI ) );
        disposables.add( workspace.onDidChangeActivePaneItem( function(item){
            if( statusbar != null ) {
                if( Std.is( item, VideoPlayer ) ) {
                    var player : VideoPlayer = item;
					/*
                    Fs.stat( player.file.getPath(), function(e,stat){
                        if( e != null ) {
                            statusbar.hide();
                            statusbar.text = '';
                        } else {
                            var mb = Std.int( stat.size / 1000000.0 );
                            statusbar.text = player.video.videoWidth+'x'+player.video.videoHeight + ', ' +mb + 'mb';
                            statusbar.show();
                        }
                    });
					*/
					statusbar.text = player.video.videoWidth+'x'+player.video.videoHeight;
					statusbar.show();
                } else {
                    statusbar.hide();
                    statusbar.text = '';
                }
            }
        }));
    }

    static function deactivate() {
        disposables.dispose();
        if( statusbar != null ) statusbar.dispose();
    }

    static function openURI( uri : String ) {
        var ext = uri.extension().toLowerCase();
        if( allowedFileTypes.has( ext ) ) {
            var player = new VideoPlayer( {
                path: uri,
                time: null,
                volume : config.get( 'videoplayer.playback.volume' ),
                play: config.get( 'videoplayer.playback.autoplay' ),
                mute: false,
            } );
            disposables.add( cast player );
            return player;
        }
        return null;
    }

    static function consumeStatusBar( pane )
        pane.addLeftTile( { item: statusbar = new Statusbar() } );

    static function deserialize( state )
        return new VideoPlayer( state );

	/*
	///TODO
	static function provideControls() {
		return {
			mute: function(){
			},
			unmute: function(){
			},
			volume: function(v:Float){
			},
			seek: function(v:Float){
			},
			rate: function(v:Float){
			},
			play: function(){
			}
			pause: function(){
			}
		}
	}
	*/

	var file : File;
	var isPlaying = false;
    var seekSpeed : Float;
    var wheelSpeed : Float;
    var commands : CompositeDisposable;
	var element : DivElement;
	var video : VideoElement;
	//var info : DivElement;

	function new( state ) {

		this.file = new File( state.path );

        seekSpeed = 1; // config.get( 'audioplayer.seek_speed' );
        wheelSpeed = 1; //config.get( 'audioplayer.wheel_speed' );

        //var workspaceStyle = window.getComputedStyle( Atom.views.getView( Atom.workspace ) );

        element = document.createDivElement();
        element.classList.add( 'videoplayer' );
        element.setAttribute( 'tabindex', '-1' );

        if( !config.get( 'videoplayer.background.transparent' ) ) {
            element.style.background = config.get( 'videoplayer.background.color' ).toHexString();
        }

		video = document.createVideoElement();
        video.controls = true;
        video.src = file.getPath();
        element.appendChild( video );

        element.addEventListener( 'DOMNodeInserted', handleInsertDOM, false );

        video.addEventListener( 'canplaythrough', handleVideoCanPlay, false );
        video.addEventListener( 'playing', handleVideoPlay, false );
        video.addEventListener( 'ended', handleVideoEnd, false );
        video.addEventListener( 'error', handleVideoError, false );
        //video.addEventListener( 'mousedown', handleMouseDown, false );
        //video.addEventListener( 'mouseup', handleMouseUp, false );
        //video.addEventListener( 'mouseout', handleMouseUp, false );
        //video.addEventListener( 'mouseup', handleMouseUp, false );
        //video.addEventListener( 'loadeddata', function(e) trace(e) );
        //video.addEventListener( 'loadedmetadata', function(e) trace(e) );
        //video.addEventListener( 'durationchange', function(e) trace(e) );

        //info = document.createDivElement();
        //info.classList.add( 'info' );
        //info.textContent = 'INFO';
        //element.appendChild( info );

        commands = new CompositeDisposable();
        addCommand( 'goto-start', function(e) {
			if( video != null ) video.currentTime = 0;
		});
        addCommand( 'goto-end', function(e) {
			if( video != null ) video.currentTime = video.duration;
		});
        addCommand( 'rate-increase', function(e) video.playbackRate += 0.1 );
        addCommand( 'rate-decrease', function(e) video.playbackRate -= 0.1 );
        addCommand( 'toggle-fullscreen', function(e) {
			toggleFullscreen();
		} );
        addCommand( 'toggle-controls', function(e) video.controls = !video.controls );
        addCommand( 'seek-backward', function(e){
			if( video != null )
            	seek( -calcSeekValue( untyped e.originalEvent != null && e.originalEvent.shiftKey ) );
        } );
        addCommand( 'seek-forward', function(e) {
			if( video != null )
            	seek( calcSeekValue( untyped e.originalEvent != null && e.originalEvent.shiftKey ) );
        } );
        addCommand( 'toggle-mute', toggleMute );
        addCommand( 'volume-increase', function(e) {
			if( video != null ) {
				video.volume = Math.min( video.volume + 0.1, 1.0 );
			}
		} );
        addCommand( 'volume-decrease', function(e) {
			if( video != null ) {
				video.volume = Math.max( video.volume - 0.1, 0.0 );
			}
		} );
        addCommand( 'toggle-playback', togglePlayback );

        if( state != null ) {
			if( state.time != null ) video.currentTime = state.time;
            if( state.volume != null ) video.volume = state.volume;
			if( state.mute ) video.muted = true;
            if( state.play ) play();
        }
	}

	public function serialize() {
        return {
            deserializer: 'VideoPlayer',
            mute: video.muted,
            path: file.getPath(),
            play: !video.paused,
            time: video.currentTime,
            volume: video.volume
        }
    }

	public function dispose() {

        commands.dispose();

        element.removeEventListener( 'DOMNodeInserted', handleInsertDOM );

        video.removeEventListener( 'canplaythrough', handleVideoCanPlay );
        video.removeEventListener( 'playing', handleVideoPlay );
        video.removeEventListener( 'ended', handleVideoEnd );
        video.removeEventListener( 'error', handleVideoError );
        video.removeEventListener( 'click', handleVideoClick );
        video.removeEventListener( 'mousewheel', handleMouseWheel );
        //video.removeEventListener( 'loadedmetadata', function(e) trace(e) );

		video.pause();
        video.remove();
        video = null;
	}

	public function getPath()
        return file.getPath();

    public function getTitle()
        return file.getBaseName();

	public function getIconName()
        return 'file-media';

    public function getURI()
            return getPath();

	public function getEncodedURI()
        return "file://" + getPath().urlEncode();

	public function isEqual( other : Dynamic )
		return Std.is( other, VideoPlayer );

	/*
	public function setScaleMode( mode : ScaleMode ) {
		switch mode {
		case Fit:
			//video.style.width = '100%';
			//video.style.height = '100%';
			//video.style.minWidth = '100%';
		//	video.style.minHeight = '100%';
		case Letterbox:
			//video.style.minWidth = null;
			//video.style.minHeight = null;
		case Original:
			video.style.width = video.videoWidth+'px';
			video.style.height = video.videoHeight+'px';
			video.style.top = '50%';
			video.style.left = '50%';
			video.style.transform = 'translate(-50%,-50%)';
		}
	}
	*/

    inline function togglePlayback()
        isPlaying ? pause() : play();

    inline function toggleMute()
        video.muted = !video.muted;

    function play() {
        if( !isPlaying ) {
            isPlaying = true;
            video.play();
        }
    }

    function pause() {
        if( isPlaying ) {
            isPlaying = false;
            video.pause();
        }
    }

    function seek( secs : Float ) : Float {
        if( secs != null && secs >= 0 && video.currentTime != null ) video.currentTime += secs;
        return video.currentTime;
    }

    function calcSeekValue( fast = false, factor = 100, min = 1, max = 30 ) {
        var v = video.duration / factor;
        v = Math.min( max, Math.max( min, v ) );
        if( fast) v *= 3;
        return v;
    }

	function addCommand<T:haxe.Constraints.Function>( name : String, fn : T ) {
		commands.add( Atom.commands.add( '.videoplayer', 'videoplayer:$name', fn ) );
	}

	function toggleFullscreen() {
		if( Atom.isFullScreen() ) {
			untyped document.webkitExitFullscreen();
		} else {
			untyped video.webkitRequestFullscreen();
		}
	}

    function handleInsertDOM(e) {
        if( isPlaying ) video.play();
    }

    function handleVideoCanPlay(e) {

		//setScaleMode( Original );

        video.removeEventListener( 'canplaythrough', handleVideoCanPlay );
		video.addEventListener( 'click', handleVideoClick, false );
        video.addEventListener( 'mousewheel', handleMouseWheel, false );

		if( statusbar != null ) {
			statusbar.text = video.videoWidth+'x'+video.videoHeight;
		}
    }

    function handleVideoPlay(e) {
        isPlaying = true;
    }

    function handleVideoEnd(e) {
        isPlaying = false;
		if( config.get( 'videoplayer.playback.loop' ) ) play();
    }

    function handleVideoError(e) {
        console.error( e );
		isPlaying = false;
		//video.classList.add( 'error' );
		Atom.notifications.addError( 'Cannot play video: '+getPath() );
    }

    function handleVideoClick(e) {
        togglePlayback();
    }

    /*
    function handleMouseDown(e) {
        video.addEventListener( 'mousemove', handleMouseMove, false );
    }

    function handleMouseUp(e) {
        video.removeEventListener( 'mousemove', handleMouseMove, false );
    }

    function handleMouseOut(e) {
        video.removeEventListener( 'mousemove', handleMouseMove, false );
    }
    */

    function handleMouseWheel(e) {
        var v = e.wheelDelta / 100 * wheelSpeed;
        if( e.ctrlKey ) {
            v *= 10;
            if( e.shiftKey ) v *= 10;
        }
        seek( v );
    }

}
