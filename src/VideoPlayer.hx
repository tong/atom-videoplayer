
import js.Browser.console;
import js.Browser.document;
import js.html.VideoElement;
import js.node.Fs;
import Atom.config;

using StringTools;

@:keep
@:expose
class VideoPlayer {

    @:allow(VideoPlayerView)
    var video : VideoElement;
    var file : atom.File;
    //var subscriptions : atom.CompositeDisposable;

    public function new( filePath : String, currentTime = 0.0 ) {

        file = new atom.File( filePath );

        video = document.createVideoElement();
        video.controls = true;
        video.autoplay = config.get( 'videoplayer.autoplay' );
        video.loop = config.get( 'videoplayer.loop' );
        video.volume = config.get( 'videoplayer.volume' );
        video.src = getPath();
        video.currentTime = currentTime;

        //subscriptions = new atom.CompositeDisposable();
    }

    /*
    public function getViewClass() {
        trace("getViewClass");
        return VideoPlayerView;
    }
    */

    public function serialize() {
        return {
            deserializer: 'VideoPlayer',
            filePath: getPath(),
            time : video.currentTime
        };
    }

    public function destroy() {
        trace("destroy");
        //subscriptions.dispose();
        var view = Atom.views.getView( this );
        view.remove();
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
        return getPath().urlEncode();
    }

    /*
    public function isEqual( other ) {
        if( !Std.is( other, VideoPlayer ) )
            return false;
        return getURI() == cast( other, VideoPlayer ).getURI();
    }
    */

    public static function deserialize( state : Dynamic ) {
        return if( sys.FileSystem.exists( state.filePath ) )
            new VideoPlayer( state.filePath, state.time );
        else {
            console.warn( 'Could not deserialize videoplayer for path '+state.filePath+' because that file no longer exists' );
            null;
        }
    }

}
