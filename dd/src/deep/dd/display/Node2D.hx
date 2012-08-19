package deep.dd.display;

import msignal.Signal;
import mt.m3d.Color;
import deep.dd.World2D;
import flash.geom.Vector3D;
import deep.dd.utils.BlendMode;
import flash.geom.Matrix3D;
import deep.dd.camera.Camera2D;
import flash.display3D.Context3D;

class Node2D
{
    public var blendMode:BlendMode;

    public var parent(default, null):Node2D;

    public var scene(default, null):Scene2D;

    public var world(get_world, null):World2D;

    public var transform(default, null):Matrix3D;
    var invalidateTransform:Bool = true;

    public var worldTransform(default, null):Matrix3D;
    var invalidateWorldTransform:Bool = true;

    public var colorTransform(default, set_colorTransform):Color;
    public var worldColorTransform(default, null):Vector3D;
    var invalidateColorTransform:Bool;

    public var alpha(default, set_alpha):Float = 1;

    public var visible:Bool = true;

    var children:Array<Node2D>;

    public var numChildren(get_numChildren, null):UInt;

    var ctx:Context3D;

    public var transformChange(default, null):Signal0;
    public var colorTransformChange(default, null):Signal0;

    public var ignoreInBatch:Bool = false;

    public function new()
    {
        blendMode = BlendMode.NORMAL;

        transformChange = new Signal0();
        colorTransformChange = new Signal0();

        children = new Array();
        transform = new Matrix3D();

        worldColorTransform = new Vector3D();
        worldTransform = new Matrix3D();

        colorTransform = null;
    }

    public function dispose():Void
    {
        if (parent != null)
        {
            parent.removeChild(this);
        }

        transformChange.removeAll();
        colorTransformChange.removeAll();

        for (child in children.copy())
        {
            child.dispose();
        }

        ctx = null;
        children = null;
        transform = null;
        worldTransform = null;
        worldColorTransform = null;
        blendMode = null;

        Reflect.setField(this, "pivot", null);
        Reflect.setField(this, "colorTransform", null);
    }

    function setParent(p:Node2D)
    {
        if (parent != null)
        {
            parent.transformChange.remove(onParentTransformChange);
            parent.colorTransformChange.remove(onParentColorChange);
        }

        parent = p;
        invalidateWorldTransform = true;
        invalidateColorTransform = true;

        if (parent != null)
        {
            parent.transformChange.add(onParentTransformChange);
            parent.colorTransformChange.add(onParentColorChange);
        }
    }

    function onParentColorChange()
    {
        invalidateColorTransform = true;
    }

    function onParentTransformChange()
    {
        invalidateWorldTransform = true;
    }

    function setScene(s:Scene2D):Void
    {
        scene = s;
        for (i in children) i.setScene(s);
    }

    function get_world():World2D
    {
        return scene != null ? scene.world : null;
    }

    // children

    function get_numChildren()
    {
        return children.length;
    }

    public function addChild(c:Node2D):Void
    {
        if (c.parent != null)
        {
            if (c.parent == this)
            {
                children.remove(c);  // small optimization
                children.push(c);
                return;
            }

            c.parent.removeChild(c);
        }
        children.push(c);
        c.setParent(this);
        if (scene != null) c.setScene(scene);
        if (ctx != null) c.init(ctx);
    }

    public function removeChild(c:Node2D):Void
    {
        children.remove(c);
        c.invalidateWorldTransform = true;
        c.parent = null;
        c.setParent(null);
        c.setScene(null);
    }
	
    public function iterator():Iterator<Node2D>
    {
        return children.iterator();
    }

    public function init(ctx:Context3D):Void
    {
        if (this.ctx != ctx)
        {
            this.ctx = ctx;
            for (i in children) i.init(ctx);
        }
    }

    public function drawStep(camera:Camera2D):Void
    {
        if (invalidateTransform) updateTransform();
        if (invalidateWorldTransform) updateWorldTransform();
        if (invalidateColorTransform) updateWorldColor();

        draw(camera);

        for (i in children) if (i.visible) i.drawStep(camera);
    }

    public function updateWorldColor()
    {
        worldColorTransform.setTo(colorTransform.r, colorTransform.g, colorTransform.b);
        worldColorTransform.w = colorTransform.a;

        if (parent != null)
        {
            var p = parent.worldColorTransform;
            worldColorTransform.x *= p.x;
            worldColorTransform.y *= p.y;
            worldColorTransform.z *= p.z;
            worldColorTransform.w *= p.w;
        }

        invalidateColorTransform = false;

        colorTransformChange.dispatch();
    }

    public function updateWorldTransform()
    {
        worldTransform.identity();
        worldTransform.append(this.transform);

        if (parent != null) worldTransform.append(parent.worldTransform);
        invalidateWorldTransform = false;
    }

    public function updateTransform()
    {
        transform.identity();
        if (pivot != null) transform.appendTranslation(-pivot.x, -pivot.y, -pivot.z);
        transform.appendScale(scaleX, scaleY, scaleZ);
        transform.appendRotation(rotationZ, Vector3D.Z_AXIS);
        transform.appendRotation(rotationY, Vector3D.Y_AXIS);
        transform.appendRotation(rotationX, Vector3D.X_AXIS);
        transform.appendTranslation(x, y, z);
        if (pivot != null) transform.appendTranslation(pivot.x, pivot.y, pivot.z);

        invalidateTransform = false;
        invalidateWorldTransform = true;

        transformChange.dispatch();
    }

    public function draw(camera:Camera2D):Void
    {
    }

    // transform

    public var pivot(default, set_pivot):Vector3D;

    function set_pivot(v)
    {
        pivot = v;
        invalidateTransform = true;
        return v;
    }

    public var x(default, set_x):Float = 0;
    public var y(default, set_y):Float = 0;
    public var z(default, set_z):Float = 0;

    public var rotationX(default, set_rotationX):Float = 0;
    public var rotationY(default, set_rotationY):Float = 0;
    public var rotationZ(default, set_rotationZ):Float = 0;

    public var scaleX(default, set_scaleX):Float = 1;
    public var scaleY(default, set_scaleY):Float = 1;
    public var scaleZ(default, set_scaleZ):Float = 1;

    function set_x(v:Float)
    {
        x = v;
        invalidateTransform = true;
        return v;
    }

    function set_y(v:Float)
    {
        y = v;
        invalidateTransform = true;
        return v;
    }

    function set_z(v:Float)
    {
        z = v;
        invalidateTransform = true;
        return v;
    }

    function set_rotationX(v:Float)
    {
        rotationX = v;
        invalidateTransform = true;
        return v;
    }

    function set_rotationY(v:Float)
    {
        rotationY = v;
        invalidateTransform = true;
        return v;
    }

    function set_rotationZ(v:Float)
    {
        rotationZ = v;
        invalidateTransform = true;
        return v;
    }

    function set_scaleX(v:Float)
    {
        scaleX = v;
        invalidateTransform = true;
        return v;
    }

    function set_scaleY(v:Float)
    {
        scaleY = v;
        invalidateTransform = true;
        return v;
    }

    function set_scaleZ(v:Float)
    {
        scaleZ = v;
        invalidateTransform = true;
        return v;
    }

    // color transform

    function set_colorTransform(c)
    {
        if (c!= null && colorTransform != null && colorTransform.eqauls(c)) return colorTransform;

        if (c == null) c = new Color(1, 1, 1, 1);

        colorTransform = c;
        invalidateColorTransform = true;

        return c;
    }

    function set_alpha(v:Float):Float
    {
        v = Color.clamp(v);
        if (v != colorTransform.a)
        {
            colorTransform.a = v;
            invalidateColorTransform = true;
        }

        return v;
    }
}
