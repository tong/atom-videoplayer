
import js.Browser.document;
import js.Browser.window;
import js.html.DivElement;
import js.html.VideoElement;
import js.node.Fs;
import atom.CompositeDisposable;
import atom.Disposable;
import atom.File;

using Lambda;
using StringTools;
using haxe.io.Path;

@:keep
@:expose
class VideoPlayer {

    static inline function __init__() untyped module.exports = VideoPlayer;

	static var allowedFileTypes = ['3gp','avi','mov','mp4','m4v','mkv','ogv','ogm','webm'];
    static var disposables : CompositeDisposable;
    static var statusbar : Statusbar;

    static function activate( state : Dynamic ) {

        trace( 'Atom-videoplayer' );

        disposables = new CompositeDisposable();

		disposables.add( Atom.workspace.addOpener( openURI ) );

        Atom.workspace.onDidChangeActivePaneItem( function(item){
            if( statusbar != null ) {
                if( Std.is( item, VideoPlayer ) ) {
                    var player : VideoPlayer = item;
                    Fs.stat( player.file.getPath(), function(e,stat){
                        if( e != null ) {
                            statusbar.hide();
                            statusbar.text = '';
                        } else {
                            var mb = Std.int( stat.size / 1000000.0 );
                            statusbar.text = player.video.videoWidth+'x'+player.video.videoHeight + ' ' +mb + 'mb';
                            statusbar.show();
                        }
                    });
                } else {
                    statusbar.hide();
                    statusbar.text = '';
                }
            }
        });
    }

    static function deactivate() {
        disposables.dispose();
        if( statusbar != null ) statusbar.dispose();
    }

    static function openURI( uri : String ) {
        var ext = uri.extension().toLowerCase();
        if( allowedFileTypes.has( ext ) ) {
            return new VideoPlayer( {
                path: uri,
                time: null,
                volume : Atom.config.get( 'videoplayer.volume' ),
                play: Atom.config.get( 'videoplayer.autoplay' ),
                mute: false,
            } );
        }
        return null;
    }

    static function consumeStatusBar( pane ) {
        pane.addRightTile( { item: statusbar = new Statusbar(), priority: 100 } );
    }

    static function deserialize( state ) {
        return new VideoPlayer( state );
    }

    ////////////////////////////////////////////////////////////////////////////

	var file : File;
    var element : DivElement;
    var video : VideoElement;
    var isPlaying : Bool;
    var seekSpeed : Float;
    var wheelSpeed : Float;
    var commands : CompositeDisposable;

	function new( state ) {

		this.file = new File( state.path );

        isPlaying = false;
        seekSpeed = 1; // config.get( 'audioplayer.seek_speed' );
        wheelSpeed = 1; //config.get( 'audioplayer.wheel_speed' );

        //var workspaceStyle = window.getComputedStyle( Atom.views.getView( Atom.workspace ) );

        element = document.createDivElement();
        element.classList.add( 'videoplayer' );
        element.setAttribute( 'tabindex', '-1' );

		video = document.createVideoElement();
        video.controls = true;
        video.src = file.getPath();
        if( state.time != null ) video.currentTime = state.time;
        if( state.volume != null ) video.volume = state.volume;
        element.appendChild( video );

        video.addEventListener( 'canplaythrough', handleVideoCanPlay, false );
        video.addEventListener( 'playing', handleVideoPlay, false );
        video.addEventListener( 'ended', handleVideoEnd, false );
        video.addEventListener( 'error', handleVideoError, false );
        video.addEventListener( 'click', handleVideoClick, false );
        video.addEventListener( 'loadedmetadata', function(e) trace(e), false );

        commands = new CompositeDisposable();
        commands.add( Atom.commands.add( element, 'videoplayer:toggle-playback', function(e) togglePlayback() ) );
        commands.add( Atom.commands.add( element, 'videoplayer:toggle-mute', function(e) toggleMute() ) );
        commands.add( Atom.commands.add( element, 'videoplayer:seek-backward', function(e) seek( -(video.duration / 10 * seekSpeed) ) ) );
        commands.add( Atom.commands.add( element, 'videoplayer:seek-forward', function(e) seek( (video.duration / 10 * seekSpeed) ) ) );
        commands.add( Atom.commands.add( element, 'videoplayer:goto-start', function(e) video.currentTime = 0 ) );
        commands.add( Atom.commands.add( element, 'videoplayer:goto-end', function(e) video.currentTime = video.duration ) );

        if( state.play ) play();
        if( state.mute ) video.muted = true;
	}

	public function serialize() {
        return {
            deserializer: 'VideoPlayer',
            path: file.getPath(),
            time: video.currentTime,
            volume: video.volume,
            play: !video.paused,
            mute: video.muted
        }
    }

	public function dispose() {

        commands.dispose();

        element.removeEventListener( 'mousewheel', handleMouseWheel );

        video.removeEventListener( 'canplaythrough', handleVideoCanPlay );
        video.removeEventListener( 'playing', handleVideoPlay );
        video.removeEventListener( 'ended', handleVideoEnd );
        video.removeEventListener( 'error', handleVideoError );
        video.removeEventListener( 'click', handleVideoClick );
        //video.removeEventListener( 'loadedmetadata', function(e) trace(e), false );

		video.pause();
        video.remove();
        video = null;
	}

	public function getPath() {
        return file.getPath();
    }

    /*
    public function getIconName() {
        return 'git-branch';
    }
    */

    public function getTitle() {
        return file.getBaseName();
    }

    public function getURI() {
        return "file://" + file.getPath().urlEncode();
    }

    /*
    public function isEqual( other ) {
        if( !Std.is( other, VideoPlayer ) )
            return false;
        return getURI() == cast( other, VideoPlayer ).getURI();
    }
    */

    inline function togglePlayback() {
        isPlaying ? pause() : play();
    }

    inline function toggleMute() {
        video.muted = !video.muted;
    }

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

    function seek( time : Float ) : Float {
        if( video.currentTime != null ) video.currentTime += time;
        return video.currentTime;
    }

    function handleVideoCanPlay(e) {

        video.removeEventListener( 'canplaythrough', handleVideoCanPlay );
        element.addEventListener( 'mousewheel', handleMouseWheel, false );

        statusbar.text = video.videoWidth+'x'+video.videoHeight;
    }

    function handleVideoPlay(e) {
    }

    function handleVideoEnd(e) {
        isPlaying = false;
        if( Atom.isFullScreen() ) Atom.toggleFullScreen();
    }

    function handleVideoError(e) {
        trace(e);
        //video.classList.add( 'error' );
        isPlaying = false;
        if( Atom.isFullScreen() ) Atom.toggleFullScreen();
    }

    function handleVideoClick(e) {
        //e.ctrlKey ? Atom.toggleFullScreen() : togglePlayback();
    }

    function handleMouseWheel(e) {
        var v = e.wheelDelta / 100 * wheelSpeed;
        if( e.ctrlKey ) {
            v *= 10;
            if( e.shiftKey ) v *= 10;
        }
        seek( v );
    }

}
