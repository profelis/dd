package ;

import deep.dd.display.Cloud2D;
import deep.dd.utils.Stats;
import deep.dd.animation.Animator;
import flash.geom.Vector3D;
import deep.dd.texture.atlas.parser.SpriteSheetParser;
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

class BatchTest
{

    var world:World2D;
    var scene:Scene2D;

    var c0:Array<Sprite2D>;
    var c:Array<Sprite2D>;

    var sp0:Sprite2D;
    var sp1:Sprite2D;

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

        var b0 = new Batch2D();
        scene.addChild(b0);


        b0.texture = new AtlasTexture2D(world.cache.getTexture(SpriteSheet), new SpriteSheetParser(39, 40, 0.5));
        b0.animator = new Animator(10);

        c0 = [];
        for (i in 0...10)
        for (j in 0...10)
        {
            var s = new Sprite2D();
            s.pivot = new Vector3D(20, 20);
            s.y = 20;
            s.animator = b0.animator.copy();
            cast(s.animator, Animator).playAnimation(null, (i*j) % 16, true, true);
            b0.addChild(s);
            c0.push(s);
            s.x = i * 40 + 20;
            s.y = j * 40 + 20;
        }

        sp0 = new Sprite2D();
        b0.addChild(sp0);
        sp0.x = 100;
        sp0.y = 100;

        sp0.addChild(sp1 = new Sprite2D());
        sp1.x = 50;

        sp0.addChild(sp1 = new Sprite2D());
        sp1.x = -50;

        var b = new Cloud2D(25);
        b.x = 250;
        //b0.addChild(b);
        b.texture = new AtlasTexture2D(world.cache.getTexture(StarlingAtlasImage), new StarlingParser(Xml.parse(Std.string(new StarlingAtlasData()))));
        b.animator = new Animator(25);
        c = [];
        for (x in 0...5)
            for (y in 0...5)
            {
                var s = new Sprite2D();
                c.push(s);
                b.addChild(s);
                s.x = x * 70;
                s.y = y * 70;
            }

        var q = new Quad2D();
        //b0.addChild(q);
        q.width = 100;
        q.height = 100;


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
        //for (i in c0) i.rotationZ ++;
        sp0.rotationZ ++;
        sp1.colorTransform = new Color(Math.random(), Math.random(), Math.random(), 1);
        sp1.rotationZ = -sp0.rotationZ;

        //world.camera.x = -world.stage.mouseX;
        //world.camera.y = -world.stage.mouseY;
    //    world.camera.scale += (Math.random()-0.5) * 0.003;
        //sp2.rotationY += 0.05;
    }


    static function main()
    {
        new BatchTest();
    }
}