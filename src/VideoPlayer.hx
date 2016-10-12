
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

    static inline function __init__() {
        untyped module.exports = VideoPlayer;
    }

	static var allowedFileTypes = ['3gp','avi','mov','mp4','m4v','mkv','ogv','ogm','webm'];

    static var disposables : CompositeDisposable;

    static function activate( state : Dynamic ) {

        trace( 'Atom-videoplayer ' );

        disposables = new CompositeDisposable();
		disposables.add( Atom.workspace.addOpener( openURI ) );
    }

    static function deactivate() {
        disposables.dispose();
        //statusbar.dispose();
    }

    static function openURI( uri : String ) {
        var ext = uri.extension().toLowerCase();
        if( allowedFileTypes.has( ext ) ) {
            return new VideoPlayer( {
                path: uri,
                play: Atom.config.get( 'video.autoplay' ),
                time: null,
                volume : Atom.config.get( 'video.volume' )
            } );
        }
        return null;
    }

    static function consumeStatusBar( pane ) {
        //pane.addRightTile( { item: new Statusbar().element, priority:0 } );
    }

    static function deserialize( state : Dynamic ) {
        return new VideoPlayer( state );
    }

    ////////////////////////////////////////////////////////////////////////////

	var file : atom.File;
    var element : DivElement;
    var video : VideoElement;
    var wheelSpeed : Float;

	function new( state ) {

        trace(state);

		this.file = new File( state.path );

        //seekSpeed = config.get( 'audioplayer.seek_speed' );
        wheelSpeed = 1; //config.get( 'audioplayer.wheel_speed' );

        var workspaceStyle = window.getComputedStyle( Atom.views.getView( Atom.workspace ) );

        element = document.createDivElement();
        element.classList.add( 'videoplayer' );
        element.setAttribute( 'tabindex', '-1' );

		video = document.createVideoElement();
        video.controls = true;
        video.src = file.getPath();
        if( state.play != null ) video.autoplay = state.play;
        if( state.time != null ) video.currentTime = state.time;
        if( state.volume != null ) video.volume = state.volume;
        element.appendChild( video );

        element.addEventListener( 'DOMNodeInserted', function(){

            video.addEventListener( 'canplaythrough', function(e) {

                element.addEventListener( 'mousewheel', handleMouseWheel, false );
            });

            /*
            player.audio.addEventListener( 'playing', handleAudioPlaying, false );
            player.audio.addEventListener( 'ended', handleAudioEnded, false );
            player.audio.addEventListener( 'error', handleAudioError, false );
            player.audio.addEventListener( 'canplaythrough', function(e) {

                waveform.color = workspaceStyle.color;
                waveform.backgroundColor = workspaceStyle.backgroundColor;
                waveform.generate( player.getPath(), function(){
                    updateMarker();
                });

                element.addEventListener( 'click', handleMouseDown, false );
                element.addEventListener( 'mousewheel', handleMouseWheel, false );
                //element.addEventListener( 'focus', function(e) trace(e) , false );
                //element.addEventListener( 'blur', function(e) handleClickVideo(e) , false );

            }, false );
            */

            window.addEventListener( 'resize', handleResize, false );

        }, false );
	}

	public function serialize() {
        return {
            deserializer: 'VideoPlayer',
            path: file.getPath(),
            play: !video.paused,
            time: video.currentTime,
            volume: video.volume
        }
    }

	public function dispose() {
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
        //getURI: -> encodeURI(@getPath()).replace(/#/g, '%23').replace(/\?/g, '%3F')
        //return "abc";// file.getPath().urlEncode();
        //return "file://" + encodeURI(file.getPath().replace(/\\/g, '/')).replace(/#/g, '%23').replace(/\?/g, '%3F')
        return "file://" + file.getPath().urlEncode();
    }

    public function isEqual( other ) {
        if( !Std.is( other, VideoPlayer ) )
            return false;
        return getURI() == cast( other, VideoPlayer ).getURI();
    }

    function seek( time : Float ) : Float {
        if( video.currentTime != null ) video.currentTime += time;
        return video.currentTime;
    }

    /*
    function setAudioPositionFromPanePosition( x : Int ) {
        //audio.currentTime = audio.duration * (x / element.offsetWidth);
    }
    */

    function handleAudioPlaying(e) {
        //trace(e);
    }

    function handleAudioEnded(e) {
    }

    function handleAudioError(e) {
    }

    function handleMouseDown(e) {
        //setAudioPositionFromPanePosition( e.layerX  );
        //element.addEventListener( 'mouseup', handleMouseUp, false );
        //element.addEventListener( 'mousemove', handleMouseMove, false );
        //element.addEventListener( 'mouseout', handleMouseOut, false );
    }

    function handleMouseUp(e) {
        //stopMouseSeek();
    }

    function handleMouseOut(e) {
        //stopMouseSeek();
    }

    function handleMouseWheel(e) {
        var v = e.wheelDelta / 100 * wheelSpeed;
        if( e.ctrlKey ) {
            v *= 10;
            if( e.shiftKey ) v *= 10;
        }
        seek( v );
    }

    function handleResize(e) {
    }
}
