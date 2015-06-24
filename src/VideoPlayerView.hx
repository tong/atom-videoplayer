
import js.Browser.document;
import js.html.Element;
import js.html.VideoElement;
import js.html.DivElement;

class VideoPlayerView {

    public var dom(default,null) : DivElement;
    public var video(default,null) : VideoElement;
    public var info(default,null) : DivElement;

    public function new() {

        dom = document.createDivElement();
        dom.classList.add( 'videoplayer' );
        dom.setAttribute( 'tabindex', '-1' );

        video = document.createVideoElement();
        dom.appendChild( video );

        info = document.createDivElement();
        info.classList.add( 'info' );
        dom.appendChild( info );
    }

    public function destroy() {
    }

    public inline function seek( time : Float ) {
        if( video.currentTime != null ) video.currentTime += time;
    }

}
