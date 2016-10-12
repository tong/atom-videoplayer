
import js.Browser.document;
import js.html.DivElement;
import js.html.SpanElement;

abstract Statusbar(DivElement) to DivElement {

	public var text(get,set) : String;
	inline function get_text() return this.textContent;
	inline function set_text(s) return this.textContent = s;

	public inline function new() {

		this = document.createDivElement();
		this.classList.add( 'status-bar-videoplayer', 'inline-block', 'icon', 'icon-device-camera-video'  );

		hide();
	}

	public inline function show() {
		this.style.display = 'inline-block';
	}

	public inline function hide() {
		this.style.display = 'none';
	}
}
