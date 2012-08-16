package deep.dd.display;

import flash.geom.Matrix3D;
import deep.dd.camera.Camera2D;
import flash.display3D.Context3D;
import deep.dd.texture.Texture2D;
import deep.dd.material.sprite2d.Sprite2DMaterial;
import deep.dd.geometry.Geometry;

class Sprite2D extends DisplayNode2D
{
    public function new(geometry:Geometry = null)
    {
        super(geometry != null ? geometry : Geometry.createTextured(), new Sprite2DMaterial());
    }

    public var drawTransform(default, null):Matrix3D;

    override public function dispose():Void
    {
        super.dispose();

        if (texture != null)
        {
            Reflect.setField(texture, "useCount", texture.useCount - 1);
            texture.dispose();
            Reflect.setField(this, "texture", null);
        }
    }

    override public function init(ctx:Context3D):Void
    {
        if (this.ctx != ctx && texture != null)
        {
            texture.init(ctx);
        }
        super.init(ctx);
    }

    override public function drawStep(camera:Camera2D):Void
    {
        if (invalidateWorldTransform) invalidateDrawTransform = true;

        super.drawStep(camera);
    }


    override public function draw(camera:Camera2D):Void
    {
        if (invalidateDrawTransform) updateDrawTransform();

        if (texture != null)
        {
            super.draw(camera);
        }
    }

    function updateDrawTransform()
    {
        if (texture.border == null)
        {
            drawTransform = worldTransform;
        }
        else
        {
            drawTransform = texture.borderMatrix.clone();
            drawTransform.append(worldTransform);
        }

        invalidateDrawTransform = false;
    }

    var invalidateDrawTransform:Bool;

    public var texture(default, set_texture):Texture2D;

    function set_texture(tex:Texture2D):Texture2D
    {
        if (tex == texture) return tex;

        if (texture != null)
        {
            texture.borderChange.remove(onBorderChange);
            Reflect.setField(texture, "useCount", texture.useCount - 1);
        }

        texture = tex;

        if (texture != null)
        {
            Reflect.setField(texture, "useCount", texture.useCount + 1);
            texture.borderChange.add(onBorderChange);
            if (ctx != null) texture.init(ctx);
            if (geometry != null) geometry.resize(texture.width, texture.height);
        }

        invalidateDrawTransform = true;

        return tex;
    }

    function onBorderChange()
    {
        invalidateDrawTransform = true;
        geometry.resize(texture.width, texture.height);
    }

    override function set_geometry(g:Geometry):Geometry
    {
        if (g == geometry) return g;

        #if debug
        if (!g.textured) throw "geometry.textured != true";
        #end

        super.set_geometry(g);
        if (geometry != null && texture != null) geometry.resize(texture.width, texture.height);

        return geometry;
    }

}
