package tests;

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

@:bitmap("../assets/test3d/haxe.png") class Image extends BitmapData {}

class Test3D extends Test
{
    inline static var nx = 9;
    inline static var ny = 12;

    var r:Node2D;

    public function new(wrld:World2D)
    {
        super(wrld);

        addChild(r = new Node2D());

        var bmp = new Image(0, 0);

        var iw:Float = bmp.width / nx;
        var ih:Float = bmp.height / ny;

        var t = new AtlasTexture2D(world.cache.getBitmapTexture(bmp), new SpriteSheetParser(iw, ih));

        var pivot = new Vector3D(iw * 0.5, ih * 0.5);
        for (y in 0...ny)
        {
            for (x in 0...nx)
            {
                var s = new Sprite2D();
                s.texture = t.getTextureById(x * ny + y);
                s.pivot = pivot;
                s.x = x * iw - bmp.width * 0.5;
                s.y = y * ih - bmp.height * 0.5;
                r.addChild(s);
            }
        }
        t.dispose();
    }

    override public function drawStep(camera:Camera2D):Void
    {
        for (c in r)
        {
            c.rotationX += 1.5;
            c.rotationY += 1.5;
        }

        r.x = world.stage.stageWidth * 0.5;
        r.y = world.stage.stageHeight * 0.5;

        super.drawStep(camera);
    }

    override public function dispose():Void
    {
        super.dispose();
        r = null;
    }


}
