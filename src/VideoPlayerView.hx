
import js.Browser.document;
import js.html.VideoElement;

@:keep
@:expose
@:forward(
    addEventListener,
    controls,
    currentTime,
    duration,
    focus,
    pause,
    play,
    removeEventListener
)
abstract VideoPlayerView(VideoElement) {

    public inline function new( path : String, volume : Float ) {

        this = document.createVideoElement();
        this.classList.add( 'videoplayer' );
        //this.setAttribute( 'tabindex', '-1' );
        //this.setAttribute( 'context', 'videoplayer' );
        this.controls = true;
        this.volume = volume;
        this.src = 'file://$path';
        //this.style.backgroundColor = backgroundColor;
        //this.addEventListener( 'DOMNodeInserted', handleAttach, false );
        //TODO Atom.config.observe( 'videoplayer.background', {}, function(color) trace(color) );
    }

    public inline function seek( time : Float ) this.currentTime = this.currentTime + time;

    public inline function destroy() {
        this.pause();
        this.remove();
        this.src = null;
    }

    /*
    function handleAttach(e) {
        this.removeEventListener( 'DOMNodeInserted', handleAttach );
        this.parentElement.style.backgroundColor = this.style.backgroundColor;
    }
    */

}
