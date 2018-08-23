
import js.Browser.document;
import js.Browser.window;
import js.Node.console;
import js.html.DivElement;
import js.html.Element;
import js.html.VideoElement;
import js.node.Fs;
import Atom.config;
import Atom.notifications;
import Atom.workspace;
import atom.CompositeDisposable;
import atom.Disposable;
import atom.File;

using Lambda;
using StringTools;
using haxe.io.Path;

@:keep
class VideoPlayer {

	static var allowedFileTypes = ['3gp','avi','mov','mp4','m4v','mkv','ogv','ogm','webm'];
    static var disposables : CompositeDisposable;
	static var statusbar : Element;

    @:expose("activate")
    static function activate( state : Dynamic ) {
        disposables = new CompositeDisposable();
		disposables.add( workspace.addOpener( openURI ) );
        disposables.add( workspace.onDidChangeActivePaneItem( function(item){
            if( Std.is( item, VideoPlayer ) ) {
				var player : VideoPlayer = item;
                var video = player.video;
				statusbar.textContent = video.videoWidth+'x'+video.videoHeight;
			} else {
				statusbar.textContent = '';
			}
        }));
    }

    @:expose("deactivate")
    static function deactivate() {
        disposables.dispose();
        if( statusbar != null ) statusbar.remove();
    }

    @:expose("deserialize")
	static function deserialize( state )
		return new VideoPlayer( state );

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

    @:expose("consumeStatusBar")
    static function consumeStatusBar( pane ) {
        if( statusbar == null ) {
            statusbar = document.createDivElement();
            statusbar.classList.add( 'status-bar-videoplayer', 'inline-block' );
            pane.addLeftTile( { item: statusbar } );
        }
	}

	var file : File;
	var element : DivElement;
	var video : VideoElement;
	var commands : CompositeDisposable;
	var shouldPlay = false;

	function new( state ) {

		this.file = new File( state.path );

        //var workspaceStyle = window.getComputedStyle( Atom.views.getView( Atom.workspace ) );

        element = document.createDivElement();
        element.classList.add( 'videoplayer' );
        element.setAttribute( 'tabindex', '-1' );

        if( !config.get( 'videoplayer.background.transparent' ) ) {
            element.style.background = config.get( 'videoplayer.background.color' ).toHexString();
        }

		video = document.createVideoElement();
		//video.classList.add( 'scale-down' );
        video.controls = true;
        video.src = file.getPath();
        element.appendChild( video );

        element.addEventListener( 'DOMNodeInserted', handleInsertDOM, false );

        video.addEventListener( 'canplaythrough', handleVideoCanPlay, false );
        video.addEventListener( 'playing', handleVideoPlay, false );
        video.addEventListener( 'ended', handleVideoEnd, false );
        video.addEventListener( 'error', handleVideoError, false );
        //video.addEventListener( 'loadeddata', function(e) trace(e) );
        //video.addEventListener( 'loadedmetadata', function(e) trace(e) );
        //video.addEventListener( 'durationchange', function(e) trace(e) );
        //video.addEventListener( 'mousedown', handleMouseDown, false );
        //video.addEventListener( 'mouseup', handleMouseUp, false );
        //video.addEventListener( 'mouseout', handleMouseUp, false );
        //video.addEventListener( 'mouseup', handleMouseUp, false );
		//video.addEventListener( 'keydown', function(e) trace(e) );

        commands = new CompositeDisposable();
		addCommand( 'play', e -> {
			togglePlayback();
		} );
		addCommand( 'mute', e -> {
			toggleMute();
		} );
		addCommand( 'seek-forward', e -> {
			var ev = e.originalEvent;
			//trace(ev.keyCode);
			var v = switch ev.keyCode {
			case 39: ev.shiftKey ? 60 : 10; // Left
			case 33: 600; // Pageup
			default: 10;
			}
			seek( v );
		} );
		addCommand( 'seek-backward', e -> {
			var ev = e.originalEvent;
			var v = switch ev.keyCode {
			case 37: ev.shiftKey ? 60 : 10; // Left
			case 34: 600; // Pagedown
			default: 10;
			}
			seek( -v );
		} );
		addCommand( 'volume-increase', e -> {
			video.volume = Math.min( video.volume + 0.1, 1.0 );
		} );
		addCommand( 'volume-decrease', e -> {
			video.volume = Math.max( video.volume - 0.1, 0.0 );
		} );
		addCommand( 'toggle-fullscreen', e -> {
			toggleFullscreen();
		} );
		addCommand( 'goto-start', e -> {
			video.currentTime = 0;
		} );
		addCommand( 'screenshot', e -> {
			var canvas = document.createCanvasElement();
			canvas.width = video.videoWidth;
			canvas.height = video.videoHeight;
			var ctx = canvas.getContext('2d');
			ctx.drawImage( video, 0, 0, canvas.width, canvas.height );
			var dataURI = canvas.toDataURL( 'image/png' );
			dataURI = dataURI.substr( 22 );
			Fs.writeFile( 'screenshot_'+video.currentTime+'.png', dataURI, { encoding: 'base64' }, function(e){
				trace(e);
			} );
		} );
		/*
		addCommand( 'volume', e -> {
			trace(e);
			//video.volume = Math.max( video.volume - 0.1, 0.0 );
		} );
		*/

        /*
		var item = Atom.contextMenu.add( untyped {
            'video': [
                //{ label: 'Fullscreen', command: 'videoplayer:toggle-fullscreen' }, // TODO Not working ?
                { label: 'Mute', command: 'videoplayer:mute' },
                { label: 'Screenshot', command: 'videoplayer:screenshot' }
            ]
        } );
        */

		//TODO listen for config changes

        if( state != null ) {
			trace( state );
			if( state.time != null ) video.currentTime = state.time;
            if( state.volume != null ) video.volume = state.volume;
			if( state.mute ) video.muted = true;
            if( state.play ) {
				//play();
				shouldPlay = true;
			}
        }
	}

	public function serialize() {
        return {
            deserializer: 'VideoPlayer',
			path: file.getPath(),
			time: video.currentTime,
			play: !video.paused,
            mute: video.muted,
            volume: video.volume
        }
    }

	public function dispose() {
        commands.dispose();
        element.removeEventListener( 'DOMNodeInserted', handleInsertDOM );
        video.removeEventListener( 'canplaythrough', handleVideoCanPlay );
		//video.removeEventListener( 'loadedmetadata', function(e) trace(e) );
        video.removeEventListener( 'playing', handleVideoPlay );
        video.removeEventListener( 'ended', handleVideoEnd );
        video.removeEventListener( 'error', handleVideoError );
        video.removeEventListener( 'click', handleVideoClick );
        video.removeEventListener( 'mousewheel', handleMouseWheel );
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

	function addCommand<T:haxe.Constraints.Function>( name : String, fn : T )
		commands.add( Atom.commands.add( untyped element, 'videoplayer:$name', fn ) );

	function seek( secs : Float ) : Float {
		video.currentTime += secs;
		return video.currentTime;
	}

	inline function togglePlayback()
		video.paused ? video.play() : video.pause();

    inline function toggleMute()
        video.muted = !video.muted;

	function toggleFullscreen() {
		if( Atom.isFullScreen() ) {
			untyped document.webkitExitFullscreen();
		} else {
			untyped video.webkitRequestFullscreen();
		}
	}

	/*
	function handleAnimationFrame( time : Float ) {
		window.requestAnimationFrame( handleAnimationFrame );
		trace(video.getVideoPlaybackQuality());
	}
	*/

    function handleInsertDOM(e) {
		//window.requestAnimationFrame( handleAnimationFrame );
    }

    function handleVideoCanPlay(e) {
        video.removeEventListener( 'canplaythrough', handleVideoCanPlay );
		video.addEventListener( 'click', handleVideoClick, false );
		video.addEventListener( 'mousewheel', handleMouseWheel, false );
		if( shouldPlay ) {
			shouldPlay = false;
			video.play();
		}
    }

    function handleVideoPlay(e) {
        statusbar.textContent = video.videoWidth+'x'+video.videoHeight;
    }

    function handleVideoEnd(e) {
		if( config.get( 'videoplayer.playback.loop' ) ) video.play();
    }

    function handleVideoError(e) {
		console.error( e );
		//video.classList.add( 'error' );
		notifications.addError( 'Cannot play video', { detail: getPath(), dismissable: true, icon: 'file-media' } );
    }

    function handleVideoClick(e) {
        togglePlayback();
    }

	function handleMouseWheel(e) {
		var v = (e.wheelDelta < 0) ? -1 : 1;
		if( e.shiftKey ) v *= 10;
		seek( v );
	}

}
