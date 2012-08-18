package ;

import com.fermmmtools.debug.Stats;
import deep.dd.texture.atlas.animation.Animator;
import deep.dd.display.Batch2D;
import deep.dd.texture.atlas.parser.StarlingParser;
import deep.dd.texture.atlas.AtlasTexture2D;
import deep.dd.display.MovieClip2D;
import deep.dd.display.Quad2D;
import deep.dd.utils.GlobalStatistics;
import mt.m3d.Color;
import deep.dd.utils.BlendMode;
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

@:bitmap("starlingAtlas/atlas.png") class StarlingAtlasImage extends BitmapData {}
@:file("starlingAtlas/atlas.xml") class StarlingAtlasData extends ByteArray {}

class Main
{

    var world:World2D;
    var scene:Scene2D;

    var c:Array<Sprite2D>;

    public function new()
    {
        var s = flash.Lib.current.stage;
        s.scaleMode = StageScaleMode.NO_SCALE;
        s.align = StageAlign.TOP_LEFT;

        s.addChild(new Stats());

        world = new World2D(Context3DRenderMode.AUTO);

        world.scene = scene = new Scene2D();

		world.antialiasing = 2;
        world.bgColor.fromInt(0x666666);

        c = [];
        var b = new Batch2D();
        scene.addChild(b);
        //b.texture = world.cache.getTexture(Image);
        b.texture = new AtlasTexture2D(world.cache.getTexture(StarlingAtlasImage), new StarlingParser(Xml.parse(Std.string(new StarlingAtlasData()))));
        b.animator = new Animator(25);
        var rots = [0.0, 30, 60, 90, 120];
        for (x in 0...20)
            for (y in 0...20)
            {
                var s = new Sprite2D();
                c.push(s);
                b.addChild(s);
                s.x = x * 50;
                s.y = y * 100;
            }


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
        for (i in c) i.colorTransform = new Color(Math.random(), Math.random(), Math.random(), 1);

        trace(GlobalStatistics.stats.get(world.ctx));
        trace(world.statistics);
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