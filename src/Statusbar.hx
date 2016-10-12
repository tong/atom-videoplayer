
import js.Browser.document;
import js.html.DivElement;

abstract Statusbar(DivElement) to DivElement {

	public var text(get,set) : String;
	inline function get_text() return this.textContent;
	inline function set_text(s) return this.textContent = s;

	public inline function new() {
		this = document.createDivElement();
		this.classList.add( 'status-bar-videoplayer', 'inline-block' );
		//this.textContent = 'VIDEOPLAYER';
	}


}
