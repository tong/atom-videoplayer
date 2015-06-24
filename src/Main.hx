
import atom.Disposable;

using Lambda;
using haxe.io.Path;

@:keep
class Main {

    static inline function __init__() untyped module.exports = Main;

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
        seek_speed: {
            "title": "Seek speed keyboard",
            "type": "number",
            "default": 0.5,
            "minimum": 0.0,
            "maximum": 1.0
        },
        wheel_speed: {
            "title": "Seek speed mousewheel",
            "type": "number",
            "default": 0.5,
            "minimum": 0.0,
            "maximum": 1.0
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
    //static var statusBar : StatusBarView;

    static function activate( state ) {

        trace( 'Atom-videoplayer' );
        //trace(state);

        //statusBar = new StatusBarView();

        viewProvider = Atom.views.addViewProvider( VideoPlayer, function(player:VideoPlayer) {
            var view = new VideoPlayerView();
            player.initialize( view );
            //player.on( 'event', function(e) trace(e) );
            return view.dom;
        });

        opener = Atom.workspace.addOpener(function(path){
            var ext = path.extension().toLowerCase();
            //var v = js.Browser.document.createVideoElement();
            //trace(v.canPlayType('video/$ext'));
            if( allowedFileTypes.has( ext ) ) {
                var player = new VideoPlayer( path );
                player.onReady = function() {
                    //statusBar.setText( player.videoWidth+'x'+player.videoHeight );
                }
                //players.push( player );
                return player;
            }
            return null;
        });
    }

    static function deactivate() {
        viewProvider.dispose();
        opener.dispose();
    }

    /*
    static function serialize() {
        return {
            players: arr
        }
    }
    */

    static function consumeStatusBar( bar ) {
        //bar.addLeftTile( { item: statusBar.dom, priority:10 } );
    }

}
