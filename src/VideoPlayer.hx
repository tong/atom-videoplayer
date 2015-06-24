
import js.Browser.window;
import Atom.config;
import atom.CompositeDisposable;
import VideoPlayerView;

using haxe.io.Path;

@:keep
class VideoPlayer  {

    public dynamic function onReady() {}

    public var path(default,null) : String;
    public var isReady(default,null) : Bool;
    public var isPlaying(default,null) : Bool;
    public var width(get,null) : Int;
    public var height(get,null) : Int;

    var seekSpeed : Float;
    var wheelSpeed : Float;
    var view : VideoPlayerView;
    var subscriptions : CompositeDisposable;

    public function new( path : String ) {

        this.path = path;

        seekSpeed = config.get( 'videoplayer.seek_speed' );
        wheelSpeed = config.get( 'videoplayer.wheel_speed' );
        isReady = isPlaying = false;
        subscriptions = new CompositeDisposable();
    }

    inline function get_width() return isReady ? view.video.videoWidth : null;
    inline function get_height() return isReady ? view.video.videoHeight : null;

    public function initialize( view : VideoPlayerView ) {

        this.view = view;

        view.video.src = 'file://$path';
        view.video.autoplay = config.get( 'videoplayer.autoplay' );
        view.video.volume = Atom.config.get( 'videoplayer.volume' );
        view.video.loop = config.get( 'videoplayer.loop' );
        view.video.controls = true;

        view.video.addEventListener( 'canplaythrough', handleCanPlay, false );

        view.dom.addEventListener( 'focus', handleFocus, false );
        view.dom.addEventListener( 'blur', handleBlur, false );
        view.dom.addEventListener( 'click', handleClick, false );
        view.dom.addEventListener( 'mousewheel', handleMouseWheel, false );
        //view.addEventListener( 'dbclick', function(e) trace(e), false );
        //view.addEventListener( 'DOMNodeRemoved', handleVideoRemove, false );
        //view.addEventListener( 'playing', handleVideoPlay, false );
        //view.addEventListener( 'error', handleVideoError, false );
        //view.addEventListener( 'ended', handleVideoEnd, false );
        //view.addEventListener( 'resize', function(e) trace(e), false );
    }

    public function destroy() {
        subscriptions.dispose();
        view.destroy();
        view.video.removeEventListener( 'canplaythrough', handleCanPlay );
        view.dom.removeEventListener( 'focus', handleBlur );
        view.dom.removeEventListener( 'blur', handleBlur );
        view.dom.removeEventListener( 'click', handleClick );
        view.dom.removeEventListener( 'mousewheel', handleMouseWheel );
    }

    public inline function getTitle() {
        return path.withoutDirectory();
    }

    public inline function getLongTitle() {
        return path.withoutDirectory();
    }

    public inline function getIconName() {
        return "file-media";
    }

    /*
    public inline function getURI() {
        trace("getURI");
        return "file-media";
    }
    */

    public inline function getPath() {
        return path;
    }

    public function play() {
        if( view != null && !isPlaying ) {
            isPlaying = true;
            view.video.play();
        }
    }

    public function pause() {
        if( view != null && isPlaying ) {
            isPlaying = false;
            view.video.pause();
        }
    }

    public function togglePlayback() : Void
        isPlaying ? pause() : play();

    function addCommand( id : String, fun )
        subscriptions.add( Atom.commands.add( 'atom-workspace', 'videoplayer:$id', function(_) fun() ) );

    function handleCanPlay(e) {
        if( !isReady ) {
            isReady = true;
            if( view.video.autoplay ) isPlaying = true;
            onReady();
        }
    }

    function handleVideoEnd(e)
        isPlaying = false;

    function handleClick(e)
        togglePlayback();

    function handleMouseWheel(e) {
        var v = e.wheelDelta / 100 * wheelSpeed;
        if( e.ctrlKey ) v *= 10;
        view.seek( v );
    }

    function handleFocus(e) {
        addCommand( 'toggle-playback', togglePlayback );
        addCommand( 'seek-forward', function() view.seek( view.video.duration / 10 * seekSpeed ) );
        addCommand( 'seek-backward', function() view.seek( -(view.video.duration / 10 * seekSpeed) ) );
        addCommand( 'goto-start', function() view.video.currentTime = 0 );
        addCommand( 'goto-end', function() view.video.currentTime = view.video.duration );
        addCommand( 'mute', function() view.video.muted = !view.video.muted );
    }

    function handleBlur(e)
        subscriptions.dispose();

}
