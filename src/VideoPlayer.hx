
import js.Browser.document;

using StringTools;

@:keep
class VideoPlayer {

    var file : atom.File;
    //var subscriptions : atom.CompositeDisposable;

    public function new( filePath : String ) {
        file = new atom.File( filePath );
        //subscriptions = new atom.CompositeDisposable();
    }

    public function getViewClass() {
        trace("getViewClass");
        return VideoPlayerView;
    }


    public function destroy() {
        //subscriptions.dispose();
        var view = Atom.views.getView( this );
        view.remove();
    }

    public function getPath() {
        return file.getPath();
    }

    public function getIconName() {
        trace("getIconName");
        return 'git-branch';
    }

    public function getTitle() {
        return file.getBaseName();
    }

    public function getURI() {
        //getURI: -> encodeURI(@getPath()).replace(/#/g, '%23').replace(/\?/g, '%3F')
        return getPath().urlEncode();
    }

    public function isEqual( other ) {
        trace( "isEqual "+other );
        if( !Std.is( other, VideoPlayer ) )
            return false;
        return getURI() == cast( other, VideoPlayer ).getURI();
    }

}
