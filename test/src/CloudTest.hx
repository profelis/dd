package ;

import deep.dd.display.render.SimpleRender;
import deep.dd.display.render.CloudRender;
import deep.dd.display.smart.SmartSprite2D;
import deep.dd.utils.Stats;
import deep.dd.animation.Animator;
import flash.geom.Vector3D;
import deep.dd.texture.atlas.parser.SpriteSheetParser;
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

class CloudTest
{

    var world:World2D;
    var scene:Scene2D;

    var b:SmartSprite2D;

    public function new()
    {
        var s = flash.Lib.current.stage;
        s.scaleMode = StageScaleMode.NO_SCALE;
        s.align = StageAlign.TOP_LEFT;

        world = new World2D(Context3DRenderMode.AUTO);

        s.addChild(new Stats(world));

        world.scene = scene = new Scene2D();

		world.antialiasing = 2;
        world.bgColor.fromInt(0x666666);

        b = new SmartSprite2D(new CloudRender());
        scene.addChild(b);
        b.texture = new AtlasTexture2D(world.cache.getTexture(StarlingAtlasImage), new StarlingParser(Xml.parse(Std.string(new StarlingAtlasData()))));
        b.animator = new Animator(25);

        for (x in 0...10)
            for (y in 0...1)
            {
                var s = new Sprite2D();
                s.extra = x;
                b.addChild(s);
                var an:Animator = cast b.animator.copy();
                s.animator = an;
                an.playAnimation(null, x, true, true);
                //s.playAnimation(null, y, true, true);
                s.x = x * 70;
                s.y = y * 70;
            }
         /*
        var q = new Sprite2D();
        q.texture = b.texture;
        scene.addChild(q);
        q.width = 100;
        q.height = 100;
           */

        s.addEventListener(Event.ENTER_FRAME, onRender);

        s.addEventListener(MouseEvent.CLICK, onClick);
    }

    function onClick(_)
    {
        b.removeChildAt(0);
        var s = new Sprite2D();
        s.x = 5.5 * 70;
        b.addChildAt(s, 5);
        trace(b.numChildren);
        //world.ctx.dispose();
		//mc.animator.playAnimation(null);
    }

    function onRender(_)
    {

        //world.camera.x = -world.stage.mouseX;
        //world.camera.y = -world.stage.mouseY;
    //    world.camera.scale += (Math.random()-0.5) * 0.003;
        //sp2.rotationY += 0.05;
    }


    static function main()
    {
        new CloudTest();
    }
}