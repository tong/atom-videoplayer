
import atom.Disposable;
import js.node.Fs;

using Lambda;
using haxe.io.Path;

@:keep
class Main {

    static inline function __init__() untyped module.exports = Main;

    static var allowedFileTypes = ['3gp','avi','mov','mp4','m4v','mkv','ogv','ogm','webm'];

    static var config = {
        autoplay: {
            "title": "Autoplay",
            "description": "Autoplay video when opened",
            "type": "boolean",
            "default": true
        },
        loop: {
            "title": "Loop Video",
            "type": "boolean",
            "default": false
        },
        seek_speed: {
            "title": "Keyboard Seek Speed",
            "type": "number",
            "default": 0.5,
            "minimum": 0.0,
            "maximum": 1.0
        },
        wheel_speed: {
            "title": "Mousewheel Seek Speed",
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
            "title": "Background Color",
            "type": "color",
            "default": "#000000"
        }
        */
    };

    static var disposables : atom.CompositeDisposable;
    static var statusbar : Statusbar;
    //static var statusbarAttached : Bool;

    static function activate( state : { players:Array<{path:String}> } ) {

        trace( 'Atom-videoplayer ' );

        //statusbarAttached = false;

        disposables = new atom.CompositeDisposable();
        disposables.add( Atom.workspace.addOpener( openURI ) );
        /*
        disposables.add( Atom.workspace.onDidChangeActivePaneItem( function(e){
                trace(e);
        } ) );
        */

        disposables.add(
            Atom.views.addViewProvider( VideoPlayer, function(player:VideoPlayer) {
                return new VideoPlayerView( player ).element;
            })
        );
    }

    static function deactivate() {
        disposables.dispose();
        statusbar.destroy();
    }

    static function consumeStatusBar( pane ) {
        //attachImageEditorStatusView( pane );
        statusbar = new Statusbar();
        pane.addLeftTile( { item: statusbar.element, priority:10 } );
    }

    /*
    static function attachImageEditorStatusView( pane ) {
        trace("attachImageEditorStatusView");
        //trace(Atom.workspace.getActivePaneItem());
        if( statusbarAttached || pane == null || !Std.is( Atom.workspace.getActivePaneItem(), VideoPlayer ) )
            return;
        trace(">>");
        var statusbar = new Statusbar( pane );
        pane.addLeftTile( { item: statusbar.element, priority:10 } );
        statusbar.attach();
        statusbarAttached = true;
    }
    */

    static function openURI( uri : String ) {
        //trace('openURI '+uri);
        var ext = uri.extension().toLowerCase();
        if( allowedFileTypes.has( ext ) ) {
            //var v = js.Browser.document.createVideoElement();
            //trace(v.canPlayType('video/$ext'));
            return new VideoPlayer( uri );
        }
        return null;
    }
}
