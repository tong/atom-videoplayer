
import js.html.Element;
import js.html.DivElement;
import js.html.MutationObserver;
import js.html.VideoElement;
import js.Browser.document;
import Atom.config;

@:keep
class VideoPlayerView {

    @:keep
    @:expose
    public var element(default,null) : Element;

    var video : VideoElement;
    var isPlaying : Bool;
    var isFullscreen : Bool;
    var seekSpeed : Float;
    var wheelSpeed : Float;
    var disposables : atom.CompositeDisposable;

    public function new( player : VideoPlayer ) {

        isPlaying = true;
        isFullscreen = false;
        seekSpeed = config.get( 'videoplayer.seek_speed' );
        wheelSpeed = config.get( 'videoplayer.wheel_speed' );

        element = document.createDivElement();
        element.classList.add( 'videoplayer' );
        //element.style.backgroundColor = config.get( 'videoplayer.background' ).toRGBAString();
        element.setAttribute( 'tabindex', '-1' );

        video = document.createVideoElement();
        video.autoplay = true;
        video.controls = true;
        video.loop = config.get( 'videoplayer.loop' );
        video.volume = config.get( 'videoplayer.volume' );
        video.src = player.getPath();
        element.appendChild( video );

        element.addEventListener( 'mousewheel', handleMouseWheel, false );
        //element.addEventListener( 'focus', function(e) trace(e) , false );
        //element.addEventListener( 'blur', function(e) handleClickVideo(e) , false );

        //video.addEventListener( 'playing', handleVideoPlay, false );
        video.addEventListener( 'click', handleClickVideo, false );
        video.addEventListener( 'ended', handleVideoEnd, false );
        video.addEventListener( 'error', function(e) {
            Atom.notifications.addWarning( 'Failed to play '+e.target.src );
            //TODO close pane
            var pane = Atom.workspace.getActivePane();
            pane.destroy();
            //player.destroy();

        }, false );

        var observer = new MutationObserver(function(mutations,o) {
            //for( m in mutations ) js.Browser.console.debug(m);
            if( isPlaying ) video.play();
        });
        //observer.observe( element, { attributes:true, childList:true, characterData:true } );
        observer.observe( element, { attributes: true } );

        disposables = new atom.CompositeDisposable();
        disposables.add( Atom.commands.add( element, 'videoplayer:toggle-playback', function(e) togglePlayback() ) );
        disposables.add( Atom.commands.add( element, 'videoplayer:toggle-mute', function(e) toggleMute() ) );
        disposables.add( Atom.commands.add( element, 'videoplayer:seek-backward', function(e) seek( -(video.duration / 10 * seekSpeed) ) ) );
        disposables.add( Atom.commands.add( element, 'videoplayer:seek-forward', function(e) seek( (video.duration / 10 * seekSpeed) ) ) );
        disposables.add( Atom.commands.add( element, 'videoplayer:goto-start', function(e) video.currentTime = 0 ) );
        disposables.add( Atom.commands.add( element, 'videoplayer:goto-end', function(e) video.currentTime = video.duration ) );
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
        //untyped video.webkitEnterFullscreen();
        //video.requestFullscreen();
        //untyped document.documentElement.webkitRequestFullscreen();
        untyped video.webkitRequestFullscreen();
        isFullscreen = true;
    }

    public function exitFullscreen() {
        //untyped video.webkitExitFullscreen();
        untyped document.webkitExitFullscreen();
        isFullscreen = false;
    }

    public function toggleFullscreen() {
        isFullscreen ? exitFullscreen() : enterFullscreen();
    }

    function handleVideoEnd(e) {
        isPlaying = false;
        if( isFullscreen ) exitFullscreen();
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
