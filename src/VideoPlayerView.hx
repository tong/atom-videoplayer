
import js.html.HtmlElement;
import js.html.Element;
import js.html.DivElement;
import js.html.MutationObserver;
import js.html.VideoElement;
import js.Browser.document;
import js.Browser.window;
import Atom.config;

@:keep
@:expose
class VideoPlayerView {

    @:keep
    @:expose
    public var element(default,null) : HtmlElement;

    var video : VideoElement;
    var isPlaying : Bool;
    var seekSpeed : Float;
    var wheelSpeed : Float;
    var disposables : atom.CompositeDisposable;

    public function new( player : VideoPlayer ) {

        this.video = player.video;

        isPlaying = true;
        seekSpeed = config.get( 'videoplayer.seek_speed' );
        wheelSpeed = config.get( 'videoplayer.wheel_speed' );

        element = document.createHtmlElement();
        element.classList.add( 'videoplayer' );
        //element.style.backgroundColor = config.get( 'videoplayer.background' ).toRGBAString();
        element.setAttribute( 'tabindex', '-1' );
        //video = document.createVideoElement();
        //video.controls = true;
        //video.autoplay = config.get( 'videoplayer.autoplay' );
        //video.loop = config.get( 'videoplayer.loop' );
        //video.volume = config.get( 'videoplayer.volume' );
        //video.src = player.getPath();
        //element.appendChild( video );
        element.appendChild( video );

        document.addEventListener( 'fullscreenchange', function(e) trace(e), false );
        document.addEventListener( 'webkitFfullscreenchange', function(e) trace(e), false );
        window.addEventListener( 'fullscreenchange', function(e) trace(e), false );
        window.addEventListener( 'webkitFfullscreenchange', function(e) trace(e), false );

        element.addEventListener( 'mousewheel', handleMouseWheel, false );
        //element.addEventListener( 'focus', function(e) trace(e) , false );
        //element.addEventListener( 'blur', function(e) handleClickVideo(e) , false );

        player.video.addEventListener( 'click', handleClickVideo, false );
        player.video.addEventListener( 'playing', handleVideoPlaying, false );
        player.video.addEventListener( 'ended', handleVideoEnd, false );
        player.video.addEventListener( 'error', function(e) {
            Atom.notifications.addWarning( 'Failed to play '+e.target.src );
            Atom.workspace.paneForURI( player.getURI() ).destroy();
            //Atom.workspace.getActivePane().destroy();
        }, false );

        window.addEventListener( 'resize', handleResize, false );

        // HACK
        var observer = new MutationObserver(function(mutations,o) {
            if( isPlaying ) {
                //video.currentTime =
                video.play();
            }
        });
        observer.observe( element, { attributes: true } );

        disposables = new atom.CompositeDisposable();
        disposables.add( Atom.commands.add( element, 'videoplayer:toggle-playback', function(e) togglePlayback() ) );
        disposables.add( Atom.commands.add( element, 'videoplayer:toggle-mute', function(e) toggleMute() ) );
        disposables.add( Atom.commands.add( element, 'videoplayer:seek-backward', function(e) seek( -(video.duration / 10 * seekSpeed) ) ) );
        disposables.add( Atom.commands.add( element, 'videoplayer:seek-forward', function(e) seek( (video.duration / 10 * seekSpeed) ) ) );
        disposables.add( Atom.commands.add( element, 'videoplayer:goto-start', function(e) video.currentTime = 0 ) );
        disposables.add( Atom.commands.add( element, 'videoplayer:goto-end', function(e) video.currentTime = video.duration ) );

        disposables.add( Atom.config.onDidChange( 'videoplayer', {}, function(e){
            var ov = e.oldValue;
            var nv = e.newValue;
            video.autoplay = nv.autoplay;
            video.loop = nv.loop;
        }) );
    }

    public function initialize( player : VideoPlayer ) {
        trace( "initialize" );
        trace( player );
    }

    public function contains() {
        trace( "contains" );
        return false;
    }

    public function destroy() {
        trace( "destroy" );
        disposables.dispose();
    }

    public function attached() {
        trace( "attached" );
    }

    public function detached() {
        trace( "detached" );
    }

    public function focus() {
        trace( "focus" );
    }

    public function onDidLoad( callback ) {
        trace( "onDidLoad "+callback );
    }

    public function getPane() {
        trace( "getPane" );
    }

    public function play() {
        if( !isPlaying ) {
            isPlaying = true;
            video.play();
        }
    }

    public function pause() {
        if( isPlaying ) {
            isPlaying = false;
            video.pause();
        }
    }

    public function seek( time : Float ) {
        if( video.currentTime != null )
            video.currentTime += time;
    }

    public function togglePlayback()
        isPlaying ? pause() : play();

    public function toggleMute()
        video.muted = !video.muted;

    public function enterFullscreen() {
        untyped video.webkitRequestFullscreen();
    }

    public function exitFullscreen() {
        untyped document.webkitExitFullscreen();
    }

    public function toggleFullscreen() {
        untyped document.webkitIsFullScreen ? exitFullscreen() : enterFullscreen();
    }

    function handleVideoPlaying(e) {
    }

    function handleVideoEnd(e) {
        isPlaying = false;
        if( untyped document.webkitIsFullScreen ) exitFullscreen();
    }

    function handleResize(e) {
        //trace(e);
    }

    function handleClickVideo(e) {
        e.ctrlKey ? toggleFullscreen() : togglePlayback();
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
