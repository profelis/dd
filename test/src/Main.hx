package ;
import deep.dd.utils.Stats;
import deep.dd.material.sprite2d.Sprite2DMaterial;
import deep.dd.texture.atlas.parser.StarlingParser;
import deep.dd.display.MovieClip2D;
import deep.dd.texture.atlas.AtlasTexture2D;
import flash.Lib;
import deep.dd.display.Sprite2D;
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

    public function new()
    {

        var s = flash.Lib.current.stage;
        s.scaleMode = StageScaleMode.NO_SCALE;
        s.align = StageAlign.TOP_LEFT;

        world = new World2D(s, Context3DRenderMode.AUTO);

	    s.addChild(new Stats(world));

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
		world.scene.addChild(mc2);
		//cast(mc2.animator, Animator).stop();


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
		//text.text = "time: " + Lib.getTimer() + "\nmouseX: " + Lib.current.stage.mouseX;
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