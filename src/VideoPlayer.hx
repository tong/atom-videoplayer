
using haxe.io.Path;

@:keep
@:expose
class VideoPlayer {

    public var path(default,null) : String;
    public var isPlaying(default,null) : Bool;
    public var seekFactor = 30;
    public var seekFastFactor = 10;
    //public var seekSuperFastFactor = 4;

    var tabTitle : String;
    var subscriptions : atom.CompositeDisposable;
    var view : VideoPlayerView;

    public function new( path : String ) {

        this.path = path;
        this.tabTitle = path.withoutDirectory();

        isPlaying = false;
        subscriptions = new atom.CompositeDisposable( );
    }

    public function initialize( view : VideoPlayerView ) {

        this.view = view;

        view.addEventListener( 'focus', handleFocus, false );
        view.addEventListener( 'blur', handleBlur, false );
        view.addEventListener( 'ended', handleVideoEnd, false );
        //view.addEventListener( 'playing', handleVideoPlay, false );
        //view.addEventListener( 'DOMNodeRemoved', handleVideoRemove, false );

        if( Atom.config.get( 'videoplayer.autoplay' ) ) play();
    }

    public function destroy() {

        trace("destroy");

        subscriptions.dispose();

        pause();

        view.removeEventListener( 'focus', handleFocus );
        view.removeEventListener( 'blur', handleBlur );
        view.removeEventListener( 'ended', handleVideoEnd );
        view.destroy();
    }

    public inline function getTitle() {
        return tabTitle;
    }

    public function play() {
        if( view != null && !isPlaying ) {
            isPlaying = true;
            view.play();
        }
    }

    public function pause() {
        if( view != null && isPlaying ) {
            isPlaying = false;
            view.pause();
        }
    }

    public function togglePlayback() : Void
        isPlaying ? pause() : play();

    function addCommand( id : String, fun )
        subscriptions.add( Atom.commands.add( 'atom-workspace', 'videoplayer:$id', function(_) fun() ) );

    function handleFocus(e) {
        addCommand( 'toggle-playback', togglePlayback );
        addCommand( 'seek-forward', function() view.seek( view.duration/seekFactor ) );
        addCommand( 'seek-backward', function() view.seek( -view.duration/seekFactor ) );
        addCommand( 'seek-forward-fast', function() view.seek( view.duration/seekFastFactor ) );
        addCommand( 'seek-backward-fast', function() view.seek( -view.duration/seekFastFactor ) );
        addCommand( 'goto-start', function() view.currentTime = 0 );
        addCommand( 'goto-end', function() view.currentTime = view.duration );
        //addCommand( 'quit', destroy );
    }

    function handleBlur(e) {
        subscriptions.dispose();
    }

    function handleVideoEnd(e)
        isPlaying = false;

}
