package tests;

/**
 *  @author Dima Granetchi <system.grand@gmail.com>, <deep@e-citrus.ru>
 */

import deep.dd.display.Quad2D;
import flash.geom.Vector3D;
import flash.geom.Rectangle;
import deep.dd.utils.Frame;
import mt.m3d.Color;
import deep.dd.World2D;
import deep.dd.display.Sprite2D;
import flash.display.BitmapData;

@:bitmap("../assets/test3d/haxe.png") class Image extends BitmapData {}

class TestTextureHit extends Test
{
    public function new(w:World2D)
    {
        super(w);

        var i = new Image(0,0);

        var t = new Sprite2D();
        t.x = 200;
        t.y = 20;
        t.texture = w.cache.getBitmapTexture(i);
        t.textureHitTest = true;

        t.mouseEnabled = true;

        t.texture.frame = new Frame(t.texture.width, t.texture.height, new Vector3D(0,0, 2, 2.5), new Rectangle(20, 30, i.width + 50, i.height + 50));

        t.onMouseOver.add(function (_, _) t.colorTransform = new Color(0, 1, 0));
        t.onMouseOut.add(function (_, _) t.colorTransform = null);

        var q = new Quad2D();
        q.displayWidth = i.width + 50;
        q.displayHeight= i.height + 50;
        q.x = t.x;
        q.y = t.y;
        addChild(q);
        q.color = 0x00FFFF;

        addChild(t);
    }
}
