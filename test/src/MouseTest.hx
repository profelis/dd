package ;

import deep.dd.utils.MouseData;
import deep.dd.display.Node2D;
import flash.geom.Rectangle;
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
/*
@:bitmap("atlas1/text.png") class Image extends BitmapData {}
@:file("atlas1/text.atlas") class Atlas extends ByteArray { }

@:bitmap("starlingAtlas/atlas.png") class StarlingAtlasImage extends BitmapData {}
@:file("starlingAtlas/atlas.xml") class StarlingAtlasData extends ByteArray {}
*/

class MouseTest
{

    var world:World2D;
    var scene:Scene2D;

    var q:Quad2D;

    public function new()
    {
        var s = flash.Lib.current.stage;
        s.scaleMode = StageScaleMode.NO_SCALE;
        s.align = StageAlign.TOP_LEFT;


        world = new World2D(Context3DRenderMode.AUTO);
        world.bounds = new Rectangle(50, 50, 400, 300);

        s.addChild(new Stats(world));

        world.scene = scene = new Scene2D();
        scene.mouseEnabled = true;

		world.antialiasing = 2;
        world.bgColor.fromInt(0x666666);


        q = new Quad2D();
        q.mouseEnabled = true;
        scene.addChild(q);
        q.update();
        q.geometry.setVertexColor(0, 0xFF0000);
        q.x = 50;
        q.y = 50;
        q.z = 0;
        //q.rotationY = 10;
        q.width = 150;
        q.height = 100;

        var mc = new MovieClip2D();
        mc.mouseEnabled = true;
        mc.texture = new AtlasTexture2D(world.cache.getTexture(SpriteSheet), new SpriteSheetParser(39, 40, 0.5));
        mc.x = 200;
        mc.scaleX = mc.scaleY = 4;
        scene.addChild(mc);
        q.alpha = 0.5;

        var mc2 = new MovieClip2D();
        mc2.mouseEnabled = true;
        mc2.texture = mc.texture;
        mc.addChild(mc2);
        mc2.y = 50;

        q.onMouseDown.add(onDown);
        mc.onMouseDown.add(onDown);
        mc2.onMouseDown.add(onDown);

        q.onMouseUp.add(onUp);
        mc.onMouseUp.add(onUp);
        mc2.onMouseUp.add(onUp);

        q.onMouseOver.add(onOver);
        mc.onMouseOver.add(onOver);
        mc2.onMouseOver.add(onOver);
        q.onMouseOut.add(onOut);
        mc.onMouseOut.add(onOut);
        mc2.onMouseOut.add(onOut);

        s.addEventListener(Event.ENTER_FRAME, onRender);

        s.addEventListener(MouseEvent.CLICK, onClick);
    }

    function onUp(n:Node2D, _)
    {
        n.alpha = 1;
    }

    function onDown(n:Node2D, md:MouseData)
    {
        n.alpha = 0.5;
        trace(md);
        trace(cast(n, Sprite2D).texture.frame);
    }

    function onOver(n:Node2D, _)
    {
        n.colorTransform = new Color(1, 0, 0, n.alpha);
    }

    function onOut(n:Node2D, _)
    {
        n.colorTransform = new Color(1, 1, 1, n.alpha);
    }

    function onClick(_)
    {
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
        new MouseTest();
    }
}