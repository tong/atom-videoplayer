
import js.Browser.document;
import js.html.Element;
import js.html.DivElement;
import js.html.SpanElement;
import js.html.VideoElement;

class Statusbar {

    public var element(default,null) : SpanElement;

    var disposables : atom.CompositeDisposable;

    public function new() {

        element = document.createSpanElement();
        element.setAttribute( 'is', 'status-bar-videoplayer' );
        element.classList.add( 'videoplayer-status', 'inline-block',  'icon', 'icon-device-camera-video' );

        disposables = new atom.CompositeDisposable();
        disposables.add( Atom.workspace.onDidChangeActivePaneItem( function(e) {
            var item = Atom.workspace.getActivePaneItem();
            if( Std.is( item, VideoPlayer ) ) {
                var player = cast( item, VideoPlayer );
                var view = Atom.views.getView( player );
                var video : VideoElement = cast view.children[0];
                video.addEventListener( 'canplaythrough', function(e){
                    var info = video.videoWidth+"x"+video.videoHeight;
                //    trace(video);
                    //trace(untyped video.webkitAudioDecodedByteCount);
                    //trace(untyped video.webkitDroppedFrameCount);
                    //trace(untyped video.webkitDroppedFrameCount);
                    //var q = video.getVideoPlaybackQuality();
                    //trace(q);
                    element.textContent = info;
                    element.style.display = 'inline-block';
                }, false );
            } else {
                element.textContent = '';
                element.style.display = 'none';
            }
        } ) );
    }

    public function attach() {
        trace("attach");
    }

    public function attached() {
        trace("attached");
    }

    public function destroy() {
        trace("destroy");
        disposables.dispose();
    }

    public function update() {
        trace("update");
    }

    public function setText( text : String ) {
        element.textContent = text;
    }
}
