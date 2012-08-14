package deep.dd.display;

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

    public var transform(get_transform, null):Matrix3D;
    var invalidateTransform:Bool = true;

    public var worldTransform(get_worldTransform, null):Matrix3D;
    var invalidateWorldTransform:Bool;

    public var visible:Bool = true;

    var children:Array<Node2D>;

    var ctx:Context3D;

    public function new()
    {
        blendMode = BlendMode.NORMAL;

        children = new Array();
        transform = new Matrix3D();
        worldTransform = new Matrix3D();
    }

    public function dispose():Void
    {
        if (parent != null)
        {
            parent.removeChild(this);
        }

        for (child in children.copy())
        {
            child.dispose();
        }

        ctx = null;
        children = null;
        transform = null;
        worldTransform = null;
        blendMode = null;

        Reflect.setField(this, "pivot", null);
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
        c.invalidateWorldTransform = true;
        c.parent = this;
        if (scene != null) c.setScene(scene);
        if (ctx != null) c.init(ctx);
    }

    public function removeChild(c:Node2D):Void
    {
        children.remove(c);
        c.invalidateWorldTransform = true;
        c.parent = null;
        c.setScene(null);
    }
	
    public function iterator():Iterator<Node2D>
    {
        return children.iterator();
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
        draw(camera);

        for (i in children) if (i.visible) i.drawStep(camera);
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

    function get_transform()
    {
        if (invalidateTransform)
        {
            invalidateTransform = false;

            transform.identity();
            if (pivot != null) transform.appendTranslation(-pivot.x, -pivot.y, -pivot.z);
            transform.appendScale(scaleX, scaleY, scaleZ);
            transform.appendRotation(rotationZ, Vector3D.Z_AXIS);
            transform.appendRotation(rotationY, Vector3D.Y_AXIS);
            transform.appendRotation(rotationX, Vector3D.X_AXIS);
            transform.appendTranslation(x, y, z);

            for (i in children) i.invalidateWorldTransform = true;
        }

        return transform;
    }

    function get_worldTransform()
    {
        if (invalidateTransform || invalidateWorldTransform)
        {
            invalidateWorldTransform = false;
            worldTransform.identity();
            worldTransform.append(this.transform);

            if (parent != null) worldTransform.append(parent.worldTransform);
        }

        return worldTransform;
    }
}
