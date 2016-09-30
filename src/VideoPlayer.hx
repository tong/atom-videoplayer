
import js.Browser.document;
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

		disposables = new CompositeDisposable();
        disposables.add( Atom.views.addViewProvider( VideoPlayer, function(player:VideoPlayer) {
            return new VideoPlayerView( player ).element;
        }));
    }

	static var allowedFileTypes = ['3gp','avi','mov','mp4','m4v','mkv','ogv','ogm','webm'];

    static var disposables : CompositeDisposable;

    static function activate( state : Dynamic ) {
        trace( 'Atom-videoplayer ' );
		disposables.add( Atom.workspace.addOpener( openURI ) );
    }

    static function deactivate() {
        disposables.dispose();
        //statusbar.dispose();
    }

    static function openURI( uri : String ) {
        var ext = uri.extension().toLowerCase();
        if( allowedFileTypes.has( ext ) ) {
            return new VideoPlayer( uri, Atom.config.get( 'videoplayer.autoplay' ) );
        }
        return null;
    }

    static function consumeStatusBar( pane ) {
        //pane.addRightTile( { item: new Statusbar().element, priority:0 } );
    }

	public var video(default,null) : VideoElement;

	var file : atom.File;

	function new( path : String, play : Bool, time = 0.0 ) {

		this.file = new File( path );

		video = document.createVideoElement();
        video.autoplay = play;
        video.controls = true;
        video.src = file.getPath();
        video.currentTime = time;
	}

	public function serialize() {
        return {
            deserializer: 'VideoPlayer',
            path: file.getPath(),
            play: !video.paused,
            time: video.currentTime
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

	public static function deserialize( state : Dynamic ) {
		return new VideoPlayer( state.path, state.play, state.time );
	}
}
