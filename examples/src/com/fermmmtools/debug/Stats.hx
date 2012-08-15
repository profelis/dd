/**
 * stats.hx
 * http://github.com/mrdoob/stats.as
 * 
 * NME port by fermmm
 * http://fermmm.wordpress.com/
 * 
 * Released under MIT license:
 * http://www.opensource.org/licenses/mit-license.php
 *
 * How to use:
 * 
 *	addChild( new Stats() );
 *
 **/

package com.fermmmtools.debug;
	
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.system.System;
import flash.text.TextField;
import flash.display.Stage;
import flash.text.TextFormat;
import Xml;
import flash.Lib;


class Stats extends Sprite {	

	static inline var GRAPH_WIDTH : Int = 70;
	static inline var XPOS : Int = 69;//width - 1
	static inline var GRAPH_HEIGHT : Int = 50;
	static inline var TEXT_HEIGHT : Int = 50;

	private var text : TextField;

	private var timer : Int;
	private var fps : Int;
	private var ms : Int;
	private var ms_prev : Int;
	private var mem : Float;
	private var mem_max : Float;

	private var graph : BitmapData;
	private var rectangle : Rectangle;
	private var alignRight : Bool;
	private var fastUpdate : Bool;

	private var fps_graph : Int;
	private var mem_graph : Int;
	private var ms_graph : Int;
	private var mem_max_graph : Int;
	private var _stage:Stage;
	
	private var fpsStr		:String;
	private var memStr		:String;
	private var memMaxStr	:String;
	private var msStr		:String;
	private var htmlText	:String;

	/**
	 * <b>Stats</b> FPS, MS and MEM, all in one.
	 */
	public function new(alignRight:Bool = true, fastUpdate:Bool = false) 
	{
		super();
		this.alignRight = alignRight;
		this.fastUpdate = fastUpdate;
		htmlText = "";
		mem_max = 0;
		fps = 0;
				
		text = new TextField();
		text.defaultTextFormat = new TextFormat("_sans", 9, null, null, null, null, null, null, null, null, null, null, -2);
		text.multiline = true;
		text.width = GRAPH_WIDTH;
		text.height = TEXT_HEIGHT;
		text.selectable = false;
		text.mouseEnabled = false;
		
		rectangle = new Rectangle(GRAPH_WIDTH - 1, 0, 1, GRAPH_HEIGHT);			

		this.addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
		this.addEventListener(Event.REMOVED_FROM_STAGE, destroy, false, 0, true);
	}

	private function init(e : Event) {

		_stage = flash.Lib.current.stage;
		graphics.beginFill(Colors.bg);
		graphics.drawRect(0, 0, GRAPH_WIDTH, TEXT_HEIGHT);
		graphics.endFill();

		this.addChild(text);
		
		graph = new BitmapData(GRAPH_WIDTH, GRAPH_HEIGHT, false, Colors.bg);
		graphics.beginBitmapFill(graph, new Matrix(1, 0, 0, 1, 0, TEXT_HEIGHT));
		graphics.drawRect(0, TEXT_HEIGHT, GRAPH_WIDTH, GRAPH_HEIGHT);

		this.addEventListener(Event.ENTER_FRAME, update);
		
		if (alignRight)
			x = Lib.current.stage.stageWidth - width;
	}

	private function destroy(e : Event) {
		
		graphics.clear();
		
		while(numChildren > 0)
			removeChildAt(0);			
		
		graph.dispose();
		
		removeEventListener(Event.ENTER_FRAME, update);
		
	}

	private function update(e : Event) {

		timer = flash.Lib.getTimer();
		
		//after a second has passed 
		if( timer - 1000 > ms_prev ) {

			mem = System.totalMemory * 0.000000954;
			mem_max = mem_max > mem ? mem_max : mem;

			fps_graph = GRAPH_HEIGHT - Std.int( Math.min(GRAPH_HEIGHT, ( fps / _stage.frameRate ) * GRAPH_HEIGHT) );

			mem_graph = GRAPH_HEIGHT - normalizeMem(mem);
			mem_max_graph = GRAPH_HEIGHT - normalizeMem(mem_max);
			//milliseconds since last frame -- this fluctuates quite a bit
			ms_graph = Std.int( GRAPH_HEIGHT - ( ( timer - ms ) >> 1 ));
			graph.scroll(-1, 0);

			graph.fillRect(rectangle, Colors.bg);
			graph.lock();
			graph.setPixel(XPOS, fps_graph, Colors.fps);
			graph.setPixel(XPOS, mem_graph, Colors.mem);
			graph.setPixel(XPOS, mem_max_graph, Colors.memmax);
			graph.setPixel(XPOS, ms_graph, Colors.ms);
			graph.unlock();

			fpsStr		= "FPS: " + fps + " / " + stage.frameRate;
			memStr		= "MEM: " + Math.round(mem);
			memMaxStr	= "MAX: " + Math.round(mem_max);


			
			//reset frame and time counters
			fps = 0;
			ms_prev = timer;
		
			if(!fastUpdate)
				text.htmlText = htmlText;
				
			return;
		}
		
		//increment number of frames which have occurred in current second
		fps++;

		msStr = "MS: " + (timer - ms);
		ms = timer;
		
		htmlText = "<font color='" + Colors.fpsCSS +"'>" + fpsStr + "</font>" +
						"<br>" +
						"<font color='" + Colors.memCSS +"'>" + memStr + "</font>" +
						"<br>" +
						"<font color='" + Colors.memmaxCSS +"'>" + memMaxStr + "</font>" +
						"<br>" +
						"<font color='" + Colors.msCSS +"'>" + msStr + "</font>";
		
		if(fastUpdate)
			text.htmlText = htmlText;
	}


	
	function normalizeMem(_mem:Float):Int {
		return Std.int( Math.min( GRAPH_HEIGHT, Math.sqrt(Math.sqrt(_mem * 5000)) ) - 2);
	}
	
}

class Colors {

	public static inline var bg : Int = 0x000033;
	public static inline var fps : Int = 0xffff00;
	public static inline var ms : Int = 0x00ff00;
	public static inline var mem : Int = 0x00ffff;
	public static inline var memmax : Int = 0xff0070;
	public static inline var bgCSS : String = "#000033";
	public static inline var fpsCSS : String = "#ffff00";
	public static inline var msCSS : String = "#00ff00";
	public static inline var memCSS : String = "#00ffff";
	public static inline var memmaxCSS : String = "#ff0070";
	
}