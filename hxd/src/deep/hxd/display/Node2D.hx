package deep.hxd.display;
import deep.hxd.World2D;
import flash.geom.Vector3D;
import deep.hxd.utils.BlendMode;
import flash.geom.Matrix3D;
import deep.hxd.camera.Camera2D;
import flash.display3D.Context3D;

class Node2D
{
    public function new()
    {
        blendMode = BlendMode.NORMAL_PREMULTIPLIED_ALPHA;

        children = new Array();
        transform = new Matrix3D();
        worldTransform = new Matrix3D();

        rotationX = 0;
        rotationY = 0;
        rotationZ = 0;
        x = 0;
        y = 0;
        z = 0;
        scaleX = 1;
        scaleY = 1;
        scaleZ = 1;

        invalidateTransform = true;
    }

    public var blendMode:BlendMode;

    public var parent(default, null):Node2D;

    public var scene(default, null):Scene2D;

    var children:Array<Node2D>;

    public var transform(get_transform, null):Matrix3D;
    var invalidateTransform:Bool;

    public var worldTransform(get_worldTransform, null):Matrix3D;
    var invalidateWorldTransform:Bool;

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
    }

    public function removeChild(c:Node2D):Void
    {
        children.remove(c);
        c.invalidateWorldTransform = true;
        c.parent = null;
        c.setScene(null);
    }

    function setScene(s:Scene2D)
    {
        scene = s;
        for (i in children) i.setScene(s);
    }

    public function iterator():Iterator<Node2D>
    {
        return children.iterator();
    }

    var ctx:Context3D;

    public function init(ctx:Context3D):Void
    {
        this.ctx = ctx;
        for (i in children) i.init(ctx);
    }

    public function drawStep(camera:Camera2D):Void
    {
        draw(camera);

        for (i in children) i.drawStep(camera);
    }

    public function draw(camera:Camera2D):Void
    {

    }

    function get_transform()
    {
        if (invalidateTransform)
        {
            invalidateTransform = false;

            transform.identity();
            if (pivot != null) transform.appendTranslation(-pivot.x, -pivot.y, -pivot.z);
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

    public var pivot(default, set_pivot):Vector3D;

    function set_pivot(v)
    {
        pivot = v;
        invalidateTransform = true;
        return pivot;
    }

    // transform

    public var x(default, set_x):Float = 0;
    public var y(default, set_y):Float = 0;
    public var z(default, set_z):Float = 0;

    public var rotationX(default, set_rotationX):Float;
    public var rotationY(default, set_rotationY):Float;
    public var rotationZ(default, set_rotationZ):Float;

    public var scaleX(default, set_scaleX):Float;
    public var scaleY(default, set_scaleY):Float;
    public var scaleZ(default, set_scaleZ):Float;

    function set_x(v:Float)
    {
        x = v;
        invalidateTransform = true;
        return x;
    }

    function set_y(v:Float)
    {
        y = v;
        invalidateTransform = true;
        return y;
    }

    function set_z(v:Float)
    {
        z = v;
        invalidateTransform = true;
        return z;
    }

    function set_rotationX(v:Float)
    {
        rotationX = v;
        invalidateTransform = true;
        return rotationX;
    }

    function set_rotationY(v:Float)
    {
        rotationY = v;
        invalidateTransform = true;
        return rotationY;
    }

    function set_rotationZ(v:Float)
    {
        rotationZ = v;
        invalidateTransform = true;
        return rotationZ;
    }

    function set_scaleX(v:Float)
    {
        scaleX = v;
        invalidateTransform = true;
        return scaleX;
    }

    function set_scaleY(v:Float)
    {
        scaleY = v;
        invalidateTransform = true;
        return scaleY;
    }

    function set_scaleZ(v:Float)
    {
        scaleZ = v;
        invalidateTransform = true;
        return scaleZ;
    }
}
