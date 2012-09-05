package;
import com.bit101.components.ComboBox;
import com.bit101.components.PushButton;
import com.bit101.components.ScrollPane;
import com.bit101.components.Window;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Matrix;
import flash.net.FileFilter;
import flash.net.FileReference;

/**
 * ...
 * @author Zaphod
 */
class TextureEditor extends Sprite
{
	public var displayData:BitmapData;
	var customData:BitmapData;
	
	var displayBg:Sprite;
	var displayBmp:Bitmap;
	
	var uploader:FileReference;
	var dataArray:Array<TextureItem>;
	
	var textures:ComboBox;
	var load:PushButton;
	var done:PushButton;
	var panel:ScrollPane;
	
	public function new(defaultBmd:BitmapData)
	{
		super();
		
		displayData = defaultBmd;
		uploader = new FileReference();
		dataArray = [];
		addEventListener(Event.ADDED_TO_STAGE, init);
	}
	
	function init(e:Event):Void 
	{
		removeEventListener(Event.ADDED_TO_STAGE, init);
		
		initUI();
		initBmpDisplay();
	}
	
	function initUI() 
	{
		var window:Window = new Window(this, 0, 0, "Texture Editor");
		window.hasMinimizeButton = true;
		window.draggable = false;
		window.setSize(350, 150);
		panel = new ScrollPane(window, 0, 0);
		panel.showGrid = true;
		panel.autoHideScrollBar = true;
		panel.setSize(350, 150);
		
		dataArray.push(new TextureItem("Default", displayData));
		textures = new ComboBox(panel, 20, 20, 'Texture', dataArray);
		textures.addEventListener(Event.SELECT, onTextureSelect);
		textures.selectedItem = dataArray[0];
		load = new PushButton(panel, 20, 50, "Load Texture", onUpload);
		done = new PushButton(panel, 20, 80, "Update Texture", onDone);
	}
	
	private function onTextureSelect(e:Event):Void 
	{
		displayData = cast(textures.selectedItem, TextureItem).data;
		showBitmap();
	}
	
	function onDone(e:Event) 
	{
		dispatchEvent(new Event(Event.COMPLETE));
	}
	
	function onUpload(e:Event) 
	{
		uploader.addEventListener(Event.SELECT, onUploadSelected);
		uploader.addEventListener(Event.CANCEL, onCancel); 
		uploader.browse([new FileFilter("Images: (*.jpeg, *.jpg, *.gif, *.png)", "*.jpeg; *.jpg; *.gif; *.png")]);
	}
	
	private function onCancel(e:Event):Void 
	{
		uploader.removeEventListener(Event.SELECT, onUploadSelected);
		uploader.removeEventListener(Event.CANCEL, onCancel);
	}
	
	function onUploadSelected(event:Event)
	{
		uploader.removeEventListener(Event.SELECT, onUploadSelected);
		uploader.addEventListener(Event.COMPLETE, onUploadCompleted);
		uploader.load();
	}
	
	function onUploadCompleted(event:Event)
	{
		uploader.removeEventListener(Event.COMPLETE, onUploadCompleted);
		var loader:Loader = new Loader();
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageLoaded);
		loader.loadBytes(uploader.data);
	}
	
	private function onImageLoaded(e:Event):Void 
	{
		var loaderInfo:LoaderInfo = cast(e.currentTarget, LoaderInfo);
		loaderInfo.removeEventListener(Event.COMPLETE, onImageLoaded);
		var loader:Loader = loaderInfo.loader;
		var bmd:BitmapData = cast(loader.content, Bitmap).bitmapData;
		var mtx:Matrix = new Matrix();
		var w:Int = bmd.width;
		var h:Int = bmd.height;
		
		if (bmd.width > 64)
		{
			mtx.scale(64 / bmd.width, 1);
			w = Std.int(w * (64 / bmd.width));
		}
		if (bmd.height > 64)
		{
			mtx.scale(1, 64 / bmd.height);
			h = Std.int(h * (64 / bmd.height));
		}
		
		if (customData != null)
		{
			customData.dispose();
		}
		customData = new BitmapData(w, h, true, 0);
		customData.draw(bmd, mtx);
		if (textures.items.length > 1)
		{
			textures.removeItemAt(1);
		}
		textures.addItem(new TextureItem("Custom", customData));
		displayData = customData;
		bmd.dispose();
		textures.selectedIndex = 1;
	}
	
	function initBmpDisplay() 
	{
		displayBg = new Sprite();
		displayBg.graphics.beginFill(0);
		displayBg.graphics.drawRect(0, 0, 128, 128);
		displayBg.graphics.endFill();
		displayBg.x = 200;
		addChild(displayBg);
		panel.content.addChild(displayBg);
		showBitmap();
	}
	
	function showBitmap() 
	{
		if (displayBg != null)
		{
			displayBg.removeChildren();
			displayBmp = new Bitmap(displayData);
			displayBmp.scaleX = displayBmp.scaleY = 2;
			displayBmp.x = (128 - displayBmp.width) / 2;
			displayBmp.y = (128 - displayBmp.height) / 2;
			displayBg.addChild(displayBmp);
		}
	}
	
}

class TextureItem
{
	public var label:String;
	public var data:BitmapData;
	
	public function new(label:String, data:BitmapData)
	{
		this.label = label;
		this.data = data;
	}
	
}