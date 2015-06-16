
import atom.Disposable;

using Lambda;
using haxe.io.Path;

@:keep
@:expose
class VideoPlayerPackage {

    static var allowedFileTypes = ['3gp','avi','mov','mp4','m4v','mkv','ogv','ogm','webm'];

    static var config = {
        autoplay: {
            "title": "Autoplay",
            "type": "boolean",
            "default": true
        },
        loop: {
            "title": "Loop video",
            "type": "boolean",
            "default": false
        },
        volume: {
            "title": "Default Volume",
            "type": "number",
            "default": 0.7,
            "minimum": 0.0,
            "maximum": 1.0
        }
        /*
        background: {
            "title": "Background color",
            "type": "color",
            "default": "rgba(0,0,0,0.7)"
        }
        */
    };

    static var opener : Disposable;
    static var viewProvider : Disposable;

    static function activate( state ) {

        trace( 'Atom-videoplayer' );

        viewProvider = Atom.views.addViewProvider( VideoPlayer, function(player:VideoPlayer) {
                //var background = Atom.config.get( 'videoplayer.background' ).toHexString();
                var view = new VideoPlayerView( player.path, Atom.config.get( 'videoplayer.volume' ) );
                player.initialize( view );
                return view;
            }
        );

        opener = Atom.workspace.addOpener(function(path){
            if( allowedFileTypes.has( path.extension() ) )
                return new VideoPlayer( path );
            return null;
        });
    }

    static function deactivate() {
        viewProvider.dispose();
        opener.dispose();
    }

    static inline function __init__() untyped module.exports = VideoPlayerPackage;

}
