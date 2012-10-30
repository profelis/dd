package ;

import flash.text.TextFormat;
import deep.dd.texture.FlashTexture2D;
import flash.text.TextField;
import deep.dd.display.render.SimpleRender;
import deep.dd.display.render.CloudRender;
import deep.dd.display.SmartSprite2D;
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

@:file("atf.atf") class AtfData extends ByteArray {}


class AtfTextureTest
{

    var world:World2D;
    var scene:Scene2D;

    var sp:Sprite2D;

    public function new()
    {
        var s = flash.Lib.current.stage;
        s.scaleMode = StageScaleMode.NO_SCALE;
        s.align = StageAlign.TOP_LEFT;

        world = new World2D(flash.Lib.current.stage, Context3DRenderMode.AUTO);

        s.addChild(new Stats(world));

        world.scene = scene = new Scene2D();

        world.antialiasing = 2;
        world.bgColor.fromInt(0x666666);

        sp = new Sprite2D();
        sp.texture = new ATFTexture2D(new AtfData());
        scene.addChild(sp);
        sp.x = 100;
        sp.y = 100;

        s.addEventListener(Event.ENTER_FRAME, onRender);

        s.addEventListener(MouseEvent.CLICK, onClick);
    }

    function onClick(_)
    {
    }

    function onRender(_)
    {
       sp.rotation ++;
//world.camera.x = -world.stage.mouseX;
//world.camera.y = -world.stage.mouseY;
//    world.camera.scale += (Math.random()-0.5) * 0.003;
//sp2.rotationY += 0.05;
    }


    static function main()
    {
        new AtfTextureTest();
    }
}