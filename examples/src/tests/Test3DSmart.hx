package tests;

import deep.dd.display.render.CloudRender;
import deep.dd.display.render.RenderBase;
import deep.dd.display.render.BatchRender;
import deep.dd.display.render.SimpleRender;
import deep.dd.display.SmartSprite2D;
import com.bit101.components.Label;
import com.bit101.components.RadioButton;
import com.bit101.components.VBox;
import flash.display.Sprite;
import haxe.FastList;
import deep.dd.display.Cloud2D;
import deep.dd.display.Node2D;
import deep.dd.display.Batch2D;
import flash.geom.Vector3D;
import deep.dd.camera.Camera2D;
import deep.dd.texture.atlas.parser.SpriteSheetParser;
import deep.dd.texture.atlas.AtlasTexture2D;
import deep.dd.display.Sprite2D;
import flash.display.BitmapData;
import mt.m3d.Color;
import deep.dd.World2D;

@:bitmap("../assets/test3d/haxe.png") class ImageSmart extends BitmapData {}

class Test3DSmart extends Test
{
    inline static var nx = 130;
    inline static var ny = 100;

    var c:SmartSprite2D;
    var t:AtlasTexture2D;

    var cont:VBox;

    public function new(wrld:World2D)
    {
        super(wrld);

        var bmp = new ImageSmart(0, 0);

        var iw:Float = bmp.width / nx;
        var ih:Float = bmp.height / ny;

        t = new AtlasTexture2D(world.cache.getBitmapTexture(bmp), new SpriteSheetParser(iw, ih));

        c = new SmartSprite2D();
        c.scaleX = c.scaleY = 2;
        c.texture = t;
        scene.addChild(c);
        var pivot = new Vector3D(iw * 0.5, ih * 0.5);
        for (y in 0...ny)
        {
            for (x in 0...nx)
            {
                var s = new Sprite2D();
                s.texture = t.getTextureById(Std.int(y * nx + x));
                //s.pivot = pivot;
                s.x = x * iw - bmp.width * 0.5;
                s.y = y * ih - bmp.height * 0.5;
                c.addChild(s);
            }
        }

        initGUI();
    }

    function initGUI()
    {
        cont = new VBox();
        cont.y = 40;
        var labels = ["simple", "batch", "cloud"];
        var action = [initSimple, initBatch, initCloud];

        for (i in 0...labels.length)
        {
            var r = new RadioButton(cont, 0, 0, labels[i], false, action[i]);
        }

        flash.Lib.current.addChild(cont.component);
    }

    function initSimple(?_)
    {
        reInit(new SimpleRender());
    }

    function initBatch(?_)
    {
        reInit(new BatchRender());
    }

    function initCloud(?_)
    {
        reInit(new CloudRender());

        // cloud auto size test
        // world.stage.addEventListener("click", function (_) { for (i in 0...40) {c.removeChild(list.first()); list.remove(list.first());} });
    }

    function reInit(r:RenderBase)
    {
        c.render = r;
        c.x = world.stage.stageWidth * 0.5;
        c.y = world.stage.stageHeight * 0.5;
    }

    override public function drawStep(camera:Camera2D):Void
    {

        for (i in c.children)
        {
            //i.rotationX += 1.5;
            //i.rotationY += 1.5;
            i.rotationZ += 10;
        }

        super.drawStep(camera);
    }

    override public function dispose():Void
    {
        super.dispose();
        c = null;
        t.dispose();
        flash.Lib.current.removeChild(cont.component);
    }


}
