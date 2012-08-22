package ;
import deep.dd.animation.Animator;
import deep.dd.display.BitmapFont2D;
import deep.dd.display.Cloud2D;
import deep.dd.display.MovieClip2D;
import deep.dd.texture.atlas.AtlasTexture2D;
import deep.dd.texture.atlas.FontAtlasTexture2D;
import deep.dd.texture.atlas.parser.AngelCodeFontParser;
import deep.dd.texture.atlas.parser.Cocos2DParser;
import deep.dd.texture.atlas.parser.StarlingParser;
import deep.dd.texture.atlas.parser.FontSheetParser;
import flash.Lib;
import mt.m3d.Color;
import deep.dd.utils.BlendMode;
import deep.dd.display.Sprite2D;
import deep.dd.display.Batch2D;
import flash.utils.ByteArray;
import deep.dd.texture.Texture2D;
import flash.display.BitmapData;
import flash.events.MouseEvent;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import deep.dd.display.Scene2D;
import flash.display3D.Context3DRenderMode;
import deep.dd.World2D;
import flash.events.Event;

@:bitmap("metalslug_monster39x40.png") class SpriteSheet extends BitmapData {}

@:bitmap("atlas1/text.png") class Image extends BitmapData {}
@:file("atlas1/text.atlas") class Atlas extends ByteArray { }

@:bitmap("otherAtlases/textureatlas_cocos2d_allformats.png") class Cocos2DAtlasImage extends BitmapData {}
@:file("otherAtlases/textureatlas_cocos2d.plist") class Cocos2DAtlasData extends ByteArray { }

@:bitmap("starlingAtlas/atlas.png") class StarlingAtlasImage extends BitmapData {}
@:file("starlingAtlas/atlas.xml") class StarlingAtlasData extends ByteArray { }

@:bitmap("NavTitle.png") class NavTitleImage extends BitmapData { }
@:file("NavTitle.fnt") class NavTitleData extends ByteArray { }

class Main
{

    var world:World2D;
    var scene:Scene2D;
	private var mc2:MovieClip2D;
	private var mc3:MovieClip2D;
	private var text:BitmapFont2D;

    public function new()
    {
        var s = flash.Lib.current.stage;
        s.scaleMode = StageScaleMode.NO_SCALE;
        s.align = StageAlign.TOP_LEFT;

        world = new World2D(Context3DRenderMode.AUTO);

        world.scene = scene = new Scene2D();

		world.antialiasing = 2;
        world.bgColor.fromInt(0x666666);

        //sp2 = new Node2D();
        //scene.addChild(sp2);

        /*var q = new Quad2D();
        q.color = 0xFF0000;
        q.width = 100;
        q.height = 100;
        scene.addChild(q);  */

        //s.tex
	//	cast(mc.texture, AtlasTexture2D).addAnimation("idle", [0]);
	//	cast(mc.animator, Animator).playAnimation("idle", 0);
	//	cast(mc.animator, Animator).playAnimation(null, 3, false);

	//	cast(mc.animator, Animator).gotoFrame(5);
	
		mc2 = new MovieClip2D();
		mc2.fps = 25;
		var st = new AtlasTexture2D(world.cache.getTexture(StarlingAtlasImage), new StarlingParser(Xml.parse(Std.string(new StarlingAtlasData()))));
		mc2.texture = st;
		mc2.scaleX = mc2.scaleY = 1.45;
	//	world.scene.addChild(mc2);
		//cast(mc2.animator, Animator).stop();

		mc3 = new MovieClip2D();
	//	mc3.texture = new AtlasTexture2D(world.cache.getTexture(StarlingAtlasImage), new StarlingParser(Xml.parse(Std.string(new StarlingAtlasData()))));
		mc3.animator = mc2.animator.copy();
        mc3.fps = 5;
        mc3.playAnimation();
	//	cast(mc3.animator, Animator).stop();
		mc3.x = 300;
		world.scene.addChild(mc3);
		
		var mc4:MovieClip2D = new MovieClip2D();
		mc4.fps = 20;
		var cocosAtlas = new AtlasTexture2D(world.cache.getTexture(Cocos2DAtlasImage), new Cocos2DParser(Xml.parse(Std.string(new Cocos2DAtlasData()))));
		mc4.texture = cocosAtlas;
		mc4.y = 200;
		world.scene.addChild(mc4);
		
		var mc5:MovieClip2D = new MovieClip2D();
		mc5.fps = 3;
		//var fontAtlas = new FontAtlasTexture2D(world.cache.getTexture(FontImage), new FontSheetParser(32, 32, " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ", 10, 0.5));
		var fontAtlas:FontAtlasTexture2D = new FontAtlasTexture2D(world.cache.getTexture(NavTitleImage), new AngelCodeFontParser(Xml.parse(Std.string(new NavTitleData())), 0.5));
		mc5.texture = fontAtlas;
		mc5.gotoFrame("@");
		mc5.x = 200;
		mc5.y = 200;
		mc5.alpha = 0.5;
		mc5.scaleX = mc5.scaleY = 3.62;
		world.scene.addChild(mc5);
		
		var mc6:MovieClip2D = new MovieClip2D();
		mc5.fps = 3;
		var fontAtlas2:FontAtlasTexture2D = new FontAtlasTexture2D(world.cache.getTexture(NavTitleImage), new AngelCodeFontParser(Xml.parse(Std.string(new NavTitleData())), 3));
		mc6.texture = fontAtlas2;
		mc6.gotoFrame("@");
		mc6.colorTransform = new Color(0, 1, 1, 1);
		mc6.x = 200;
		mc6.y = 200;
		mc6.scaleX = mc6.scaleY = 3.62;
		world.scene.addChild(mc6);
		
		text = new BitmapFont2D(new Cloud2D(100));
	//	var fontAtlas = new FontAtlasTexture2D(world.cache.getTexture(NavTitleImage), new AngelCodeFontParser(Xml.parse(Std.string(new NavTitleData())), 0.5));
		text.font = fontAtlas;
		text.multiLine = true;
		text.fixedWidth = false;
		text.text = "Hello World!!!\nmulti!";
		world.scene.addChild(text);
		
        /*var b = new Batch2D();
        scene.addChild(b);
        b.texture = world.cache.getTexture(Image);
        var rots = [0.0, 30, 60, 90, 120];
        for (i in 0...5)
        {
            var s = new Sprite2D();
            b.addChild(s);
            s.x = i * 128;
            //s.y = i * 50;
            //s.rotationZ = rots[i];
            //s.colorTransform = new Color(Math.random(),Math.random(),Math.random(), 1);
        }*/

       /* mc = new MovieClip2D();
        mc.fps = 5;
        mc.scaleX = mc.scaleY = 5;
        mc.texture = new AtlasTexture2D(world.cache.getTexture(SpriteSheet), new SpriteSheetParser(39, 40, 5));
        mc.colorTransform = new Color(1, 0, 0, 1);
        mc.y = 200;

        world.scene.addChild(mc);*/

        s.addEventListener(Event.ENTER_FRAME, onRender);

        s.addEventListener(MouseEvent.CLICK, onClick);
    }

    function onClick(_)
    {
        //world.ctx.dispose();
		//mc.animator.playAnimation(null);
		
    }

    function onRender(_)
    {
       /*trace(cast(mc2.animator, Animator).isPlaying);
       trace(mc2.textureFrame);*/
		text.text = "time: " + Lib.getTimer() + "\nmouseX: " + Lib.current.stage.mouseY;
		//world.camera.x = -world.stage.mouseX;
        //world.camera.y = -world.stage.mouseY;
    //    world.camera.scale += (Math.random()-0.5) * 0.003;
        //sp2.rotationY += 0.05;
    }


    static function main()
    {
        new Main();
    }
}