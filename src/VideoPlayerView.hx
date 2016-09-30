
import js.html.AudioElement;
import js.html.CSSStyleDeclaration;
import js.html.DivElement;
import js.html.Element;
import js.html.MutationObserver;
import js.Browser.document;
import js.Browser.window;
import Atom.config;

@:keep
@:expose
class VideoPlayerView {

    public var element(default,null) : Element;

    var player : VideoPlayer;

    var wheelSpeed : Float;
    var animationFrameId : Int;

    public function new( player : VideoPlayer ) {

        this.player = player;

        //seekSpeed = config.get( 'audioplayer.seek_speed' );
        wheelSpeed = 1; //config.get( 'audioplayer.wheel_speed' );

        var workspaceStyle = window.getComputedStyle( Atom.views.getView( Atom.workspace ) );

        element = document.createDivElement();
        element.classList.add( 'videoplayer' );
        element.setAttribute( 'tabindex', '-1' );

        element.appendChild( player.video );

        element.addEventListener( 'DOMNodeInserted', function(){

            player.video.addEventListener( 'canplaythrough', function(e) {

                element.addEventListener( 'mousewheel', handleMouseWheel, false );
            });

            /*
            player.audio.addEventListener( 'playing', handleAudioPlaying, false );
            player.audio.addEventListener( 'ended', handleAudioEnded, false );
            player.audio.addEventListener( 'error', handleAudioError, false );
            player.audio.addEventListener( 'canplaythrough', function(e) {

                waveform.color = workspaceStyle.color;
                waveform.backgroundColor = workspaceStyle.backgroundColor;
                waveform.generate( player.getPath(), function(){
                    updateMarker();
                });

                element.addEventListener( 'click', handleMouseDown, false );
                element.addEventListener( 'mousewheel', handleMouseWheel, false );
                //element.addEventListener( 'focus', function(e) trace(e) , false );
                //element.addEventListener( 'blur', function(e) handleClickVideo(e) , false );

            }, false );
            */


        }, false );

        window.addEventListener( 'resize', handleResize, false );
    }

    /*
    public function attach() {
        trace("attach");
    }

    public function attached() {
        trace("attached");
    }

    public function dispose() {
    }
    */

    function update( time : Float ) {

        animationFrameId = window.requestAnimationFrame( update );
        updateMarker();

        /*
        ctx.fillStyle = '#fff';
    	for( i in 0...frequencyData.length ) {
			ctx.fillRect( i, 0, 1, frequencyData[i] / 256 * h );
		}
        */
    }

    function seek( time : Float ) : Float {
        if( player.video.currentTime != null ) player.video.currentTime += time;
        return player.video.currentTime;
    }

    /*
    function setAudioPositionFromPanePosition( x : Int ) {
        //player.audio.currentTime = player.audio.duration * (x / element.offsetWidth);
    }
    */

    function updateMarker() {
        var percentPlayed = player.video.currentTime / player.video.duration;
        //marker.style.left = (percentPlayed * element.offsetWidth )+'px';
    }

    function handleAudioPlaying(e) {
        //trace(e);
        animationFrameId = window.requestAnimationFrame( update );
    }

    function handleAudioEnded(e) {
    }

    function handleAudioError(e) {
    }

    function handleMouseDown(e) {
        //setAudioPositionFromPanePosition( e.layerX  );
        //element.addEventListener( 'mouseup', handleMouseUp, false );
        //element.addEventListener( 'mousemove', handleMouseMove, false );
        //element.addEventListener( 'mouseout', handleMouseOut, false );
    }

    function handleMouseUp(e) {
        //stopMouseSeek();
    }

    function handleMouseOut(e) {
        //stopMouseSeek();
    }

    function handleMouseWheel(e) {
        var v = e.wheelDelta / 100 * wheelSpeed;
        if( e.ctrlKey ) {
            v *= 10;
            if( e.shiftKey ) v *= 10;
        }
        seek( v );
    }

    function handleResize(e) {
    }
}

/*
@:keep

    public var element(default,null) : Element;

    var audio : AudioElement;
    var isPlaying : Bool;
    var seekSpeed : Float;
    var wheelSpeed : Float;
    var disposables : atom.CompositeDisposable;

    var workspaceStyle : CSSStyleDeclaration;
    var waveform : Waveform;
    var marker : DivElement;
    var animationFrameId : Int;

    public function new( player : AudioPlayer ) {

        //var editorConfig = Atom.config.get( 'editor' );

        workspaceStyle = window.getComputedStyle( Atom.views.getView( Atom.workspace ) );

        isPlaying = true;
        //seekSpeed = config.get( 'videoplayer.seek_speed' );
        //wheelSpeed = config.get( 'videoplayer.wheel_speed' );

        element = document.createDivElement();
        element.classList.add( 'audioplayer' );
        element.setAttribute( 'tabindex', '-1' );

        //trace(workspaceStyle.color);

        waveform = new Waveform( workspaceStyle.color, workspaceStyle.backgroundColor );
        element.appendChild( waveform.canvas );

        marker = document.createDivElement();
        marker.classList.add( 'marker' );
        element.appendChild( marker );

        audio = document.createAudioElement();
        audio.controls = true;
        audio.autoplay = config.get( 'audioplayer.autoplay' );
        //audio.loop = true; //config.get( 'audioplayer.loop' );
        //audio.volume = config.get( 'audioplayer.volume' );
        audio.src = player.getPath();
        element.appendChild( audio );

        element.addEventListener( 'click', handleMouseDown, false );
        element.addEventListener( 'mousewheel', handleMouseWheel, false );
        //element.addEventListener( 'focus', function(e) trace(e) , false );
        //element.addEventListener( 'blur', function(e) handleClickVideo(e) , false );

        audio.addEventListener( 'playing', handleAudioPlaying, false );
        audio.addEventListener( 'ended', handleAudioEnd, false );
        audio.addEventListener( 'error', function(e) {
            //Atom.notifications.addWarning( 'Failed to play '+e.target.src );
            //Atom.workspace.paneForURI( player.getURI() ).destroy();
            //Atom.workspace.getActivePane().destroy();
        }, false );

        window.addEventListener( 'resize', handleResize, false );

        /*
        var observer = new MutationObserver(function(mutations,o) {
            //if( isPlaying ) audio.play();
        });
        //observer.observe( element, { attributes: true } );
        * /

        disposables = new atom.CompositeDisposable();
        disposables.add( Atom.commands.add( element, 'audioplayer:toggle-playback', function(e) togglePlayback() ) );
        disposables.add( Atom.commands.add( element, 'audioplayer:toggle-mute', function(e) toggleMute() ) );
        disposables.add( Atom.commands.add( element, 'audioplayer:seek-backward', function(e) seek( -(audio.duration / 10 * seekSpeed) ) ) );
        disposables.add( Atom.commands.add( element, 'audioplayer:seek-forward', function(e) seek( (audio.duration / 10 * seekSpeed) ) ) );
        disposables.add( Atom.commands.add( element, 'audioplayer:goto-start', function(e) audio.currentTime = 0 ) );
        disposables.add( Atom.commands.add( element, 'audioplayer:goto-end', function(e) audio.currentTime = audio.duration ) );

        disposables.add( Atom.config.onDidChange( 'audioplayer', {}, function(e){
            var ov = e.oldValue;
            var nv = e.newValue;
            audio.autoplay = nv.autoplay;
            audio.loop = nv.loop;
        }) );

        waveform.generate( player.getPath(), function(){

        });

        animationFrameId = window.requestAnimationFrame( update );
    }

    function update( time : Float ) {

        animationFrameId = window.requestAnimationFrame( update );

        var percentPlayed = audio.currentTime / audio.duration;
        marker.style.left = (percentPlayed * element.offsetWidth )+'px';
    }

    public function destroy() {

        element.removeEventListener( 'mousewheel', handleMouseWheel );
        element.removeEventListener( 'click', handleMouseDown );

        audio.removeEventListener( 'playing', handleAudioPlaying );
        audio.removeEventListener( 'ended', handleAudioEnd );
        audio.remove();

        disposables.dispose();

        if( animationFrameId != null ) window.cancelAnimationFrame( animationFrameId );
    }

    public function attached() {
        trace( "attached" );
    }

    public function detached() {
        trace( "detached" );
    }

    public function focus() {
        trace( "focus" );
    }

    public function onDidLoad( callback ) {
        trace( "onDidLoad "+callback );
    }

    public function getPane() {
        trace( "getPane" );
    }

    public function play() {
        if( !isPlaying ) {
            isPlaying = true;
            audio.play();
        }
    }

    public function pause() {
        if( isPlaying ) {
            isPlaying = false;
            audio.pause();
        }
    }

    public function seek( time : Float ) : Float {
        if( audio.currentTime != null ) audio.currentTime += time;
        return audio.currentTime;
    }

    public function togglePlayback()
        isPlaying ? pause() : play();

    public function toggleMute()
        audio.muted = !audio.muted;

    function handleAudioPlaying(e) {
    }

    function handleAudioEnd(e) {
        isPlaying = false;
    }

    function handleMouseDown(e) {
        setAudioPositionFromPanePosition( e.layerX  );
        //element.addEventListener( 'mouseup', handleMouseUp, false );
        //element.addEventListener( 'mousemove', handleMouseMove, false );
        //element.addEventListener( 'mouseout', handleMouseOut, false );
    }

    function handleMouseUp(e) {
        //stopMouseSeek();
    }

    function handleMouseOut(e) {
        //stopMouseSeek();
    }

    function handleMouseMove(e) {
        //setAudioPositionFromPanePosition( e.layerX  );
    }

    function stopMouseSeek() {
        //element.removeEventListener( 'mouseup', handleMouseUp );
        //element.removeEventListener( 'mousemove', handleMouseMove );
        //element.removeEventListener( 'mouseout', handleMouseOut );
    }

    function setAudioPositionFromPanePosition( x : Int ) {
        audio.currentTime = audio.duration * (x / element.offsetWidth);
    }

    function handleMouseWheel(e) {
        var v = e.wheelDelta / 100 * wheelSpeed;
        if( e.ctrlKey ) {
            v *= 10;
            if( e.shiftKey ) v *= 10;
        }
        seek( v );
    }

    function handleResize(e) {
        waveform.resize();
    }
}
*/
