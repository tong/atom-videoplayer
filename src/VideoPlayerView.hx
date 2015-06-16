
import js.Browser.document;
import js.html.Element;
import js.html.VideoElement;

@:forward(
    addEventListener,
    controls,
    currentTime,
    duration,
    focus,
    loop,
    muted,
    pause,
    play,
    removeEventListener
)
abstract VideoPlayerView(VideoElement) {

    public inline function new( path : String, volume : Float ) {
        this = document.createVideoElement();
        this.classList.add( 'videoplayer' );
        this.setAttribute( 'tabindex', '-1' );
        //this.setAttribute( 'context', 'videoplayer' );
        this.controls = true;
        this.volume = volume;
        this.src = 'file://$path';
        //this.style.backgroundColor = backgroundColor;
        this.addEventListener( 'DOMNodeInserted', handleInsert, false );
        //TODO Atom.config.observe( 'videoplayer.background', {}, function(color) trace(color) );
    }

    public inline function seek( time : Float ) {
        if( this.currentTime != null )
            this.currentTime = this.currentTime + time;
    }

    public inline function destroy() {
        this.removeEventListener( 'mousewheel', handleMouseWheel );
        this.removeEventListener( 'dblclick', handleDoubleClick );
        this.removeEventListener( 'DOMNodeInserted', handleInsert );
        this.pause();
        this.remove();
        this.src = null;
    }

    function handleInsert(e) {
        this.removeEventListener( 'DOMNodeInserted', handleInsert );
        this.addEventListener( 'mousewheel', handleMouseWheel, false );
        this.addEventListener( 'dblclick', handleDoubleClick, false );
        this.parentElement.style.backgroundColor = this.style.backgroundColor;
    }

    function handleMouseWheel(e) {
        seek( -e.wheelDelta/100 );
    }

    function handleDoubleClick(e) {
        if( untyped document.webkitFullscreenEnabled ) {
            //TODO not working
            untyped document.documentElement.webkitRequestFullscreen();
        }
    }

}
