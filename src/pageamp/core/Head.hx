/*
 * Copyright (c) 2018-2020 Ubimate Technologies Ltd and PageAmp contributors.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

package pageamp.core;

import pageamp.util.PropertyTool.Props;
import pageamp.util.ArrayTool;
import pageamp.web.DomTools;
import pageamp.web.ColorTools;
using StringTools;
using pageamp.util.ArrayTool;
using pageamp.util.PropertyTool;
using pageamp.web.DomTools;

//TODO: adds link tag for google fonts in both the server and the client
class Head extends Element {

	public function new(parent:Element, props:Props, ?cb:Dynamic->Void) {
		super(parent, props, cb);
#if !client
		page.createDomElement('script', {
			src: '/.${Const.FRAMEWORK_NAME}/res/js/scrollIntoViewIfNeeded.js'
		}, e);
#end
	}

	override function init() {
		var e = page.doc.domGetHead();
		props = props.set(Element.NAME_PROP, 'head');
		e != null ? props.set(Element.ELEMENT_PROP, e) : null;
		super.init();
		initStylingApi();
	}

	// =========================================================================
	// CSS API
	// =========================================================================
	static inline var GOOGLE_FONT = 'https://fonts.googleapis.com/css?family=';
	var fonts = new Map<String,DomElement>();

	#if !debug inline #end
	function initStylingApi() {

		set('cssVendorize', function(s:String) {
			return '-moz-$s;-webkit-$s;-ms-$s;$s';
		});

		set('cssVendorize2', function(prefix:String, s:String) {
			return '$prefix-moz-$s;$prefix-webkit-$s;$prefix-ms-$s;$prefix$s';
		});

		// e.g. cssGoogleFont('Lato:300,400,700') adds link and returns '"Lato"'
		set('cssGoogleFont', function(name:String) {
#if (server || builder)
			if (!fonts.exists(name)) {
				var styles = page.domGetByTagName('style');
				var before = ArrayTool.peek(untyped styles);
				var link = page.createDomElement('link', {
					rel: 'stylesheet',
					type: 'text/css',
					href: GOOGLE_FONT + name.split(' ').join('+'),
				}, e, before);
				fonts.set(name, link);
			}
#end
			return '"' + name.split(":")[0] + '"';
		}).unlink();

		set('cssMakeSelectable', function() {
			return '-webkit-touch-callout:text;'
			+ '-webkit-user-select:text;'
			+ '-khtml-user-select:text;'
			+ '-moz-user-select:text;'
			+ '-ms-user-select:text;'
			+ 'user-select:text;';
		}).unlink();

		set('cssMakeNonSelectable', function() {
			return '-webkit-touch-callout:none;'
			+ '-webkit-user-select:none;'
			+ '-khtml-user-select:none;'
			+ '-moz-user-select:none;'
			+ '-ms-user-select:none;'
			+ 'user-select:none;';
		}).unlink();

		// http://webdesignerwall.com/tutorials/cross-browser-css-gradient
		set('cssMakeVGradient', function(bg1, bg2) {
			bg1 = ColorTools.fullRgb(bg1);
			bg2 = ColorTools.fullRgb(bg2);
			return 'background-color:$bg1;'
			+ 'filter:progid:DXImageTransform.Microsoft.gradient'
			+ '(startColorstr=\'${bg1}\', endColorstr=\'${bg2}\');'
			+ 'background:-webkit-gradient(linear, left top,'
			+ ' left bottom, from($bg1), to($bg2));'
			+ 'background:-moz-linear-gradient(top, $bg1, $bg2);';
		}).unlink();

		// ...drop-shadow-with-css-for-all-web-browsers
		// https://tinyurl.com/yckn4rk
		set('cssMakeShadow', function(x='0px', y='0px', radius='0px', col='#000') {
			//TODO: old IEs
			return '-moz-box-shadow:$x $y $radius $col;'
			+ '-webkit-box-shadow:$x $y $radius $col;'
			+ '-box-shadow:$x $y $radius $col;'
			+ 'box-shadow:$x $y $radius $col;';
		}).unlink();

		set('cssMakeInsetShadow', function(x=0, y=0, r=4, col='#000') {
			return '-moz-box-shadow:${x}px ${y}px ${r}px $col inset;\n'
			+ '-webkit-box-shadow:${x}px ${y}px ${r}px $col inset;\n'
			+ '-box-shadow:${x}px ${y}px ${r}px $col inset;\n'
			+ 'box-shadow:${x}px ${y}px ${r}px $col inset';
		}).unlink();

		set('cssFullRgb', ColorTools.fullRgb).unlink();
		set('cssColor2Components', ColorTools.color2Components).unlink();
		set('cssComponents2Color', ColorTools.components2Color).unlink();
		set('cssColorOffset', ColorTools.colorOffset).unlink();
		set('cssCounterColor', ColorTools.counterColor).unlink();
		set('cssColorMix', ColorTools.mix).unlink();

	}

}