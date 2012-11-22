package deep.dd.display;

import flash.geom.Point;
import flash.geom.Rectangle;
import msignal.Signal.Signal1;
import msignal.Signal.Signal2;
import Reflect;
import deep.dd.utils.FastListUtils;
import flash.Vector;
import deep.dd.utils.MouseData;
import flash.events.TouchEvent;
import flash.events.MouseEvent;
import msignal.Signal;
import haxe.FastList;
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
    public var world(default, null):World2D;

    public var extra:Dynamic;

    public var transform(get_transform, null):Matrix3D;
    /**
    * @private
    */
    public var invalidateTransform:Bool = true;

    public var worldTransform(get_worldTransform, null):Matrix3D;
    public var invertWorldTransform(get_invertWorldTransform, null):Matrix3D;
    /**
    * @private
    */
    public var invalidateWorldTransform:Bool = true;
    /**
    * @private
    */
    public var invalidateInvertWorldTransform:Bool = true;

    public var colorTransform(default, set_colorTransform):Color;
    public var worldColorTransform(get_worldColorTransform, null):Vector3D;
    /**
    * @private
    */
    public var invalidateColorTransform:Bool;

    public var alpha(default, set_alpha):Float = 1;

    public var visible(default, set_visible):Bool = true;

    function set_visible(v)
    {
        visible = v;
        if (Reflect.hasField(this, "onVisibleChange")) onVisibleChange.dispatch(this);
        return visible;
    }

    /**
    * @private
    */
    public var children(default, null):FastList<Node2D>;
    var childrenUtils:FastListUtils<Node2D>;

    public var numChildren(default, null):UInt = 0;

    var ctx:Context3D;

    public var mouseEnabled:Bool = false;
    public var mouseChildren:Bool = true;
    public var mouseX(get_mouseX, null):Float = 0/0; // NaN
    public var mouseY(get_mouseY, null):Float = 0/0;

    var oldMouseOver:Bool = false;
    public var mouseOver(default, null):Bool = false;
    public var mouseDown(default, null):Bool = false;

    public var ignoreInBatch:Bool = false;

    public var onTransformChange(default, null):Signal1<Node2D>;
    public var onWorldTransformChange(default, null):Signal1<Node2D>;
    public var onColorTransformChange(default, null):Signal1<Node2D>;
    public var onVisibleChange(get_onVisibleChange, null):Signal1<Node2D>;

    public var onMouseOver(get_onMouseOver, null):Signal2<Node2D, MouseData>;
    public var onMouseOut(get_onMouseOut, null):Signal2<Node2D, MouseData>;
    public var onMouseDown(get_onMouseDown, null):Signal2<Node2D, MouseData>;
    public var onMouseUp(get_onMouseUp, null):Signal2<Node2D, MouseData>;

    public var onWorld(get_onWorld, null):Signal2<World2D, World2D>;
    public var onScene(get_onScene, null):Signal2<Scene2D, Scene2D>;

    function get_onMouseOver() { if (onMouseOver == null) onMouseOver = new Signal2<Node2D, MouseData>(); return onMouseOver; }
    function get_onMouseOut() { if (onMouseOut == null) onMouseOut = new Signal2<Node2D, MouseData>(); return onMouseOut; }
    function get_onMouseDown() { if (onMouseDown == null) onMouseDown = new Signal2<Node2D, MouseData>(); return onMouseDown; }
    function get_onMouseUp() { if (onMouseUp == null) onMouseUp = new Signal2<Node2D, MouseData>(); return onMouseUp; }
    function get_onWorld() { if (onWorld == null) onWorld = new Signal2<World2D, World2D>(); return onWorld; }
    function get_onScene() { if (onScene == null) onScene = new Signal2<Scene2D, Scene2D>(); return onScene; }
    function get_onVisibleChange() { if (onVisibleChange == null) onVisibleChange = new Signal1<Node2D>(); return onVisibleChange; }

    static var uid:Int = 0;

    public var name:String;
	
    /**
    * @private
    */
    public var invalidateBounds(default, set_invalidateBounds):Bool = true;

    function set_invalidateBounds(v:Bool):Bool
    {
        invalidateBounds = v;
        if (v && parent != null) parent.invalidateBounds = v;

        return v;
    }

	public var bounds(get_bounds, null):Rectangle;
	var _boundRect2:Rectangle;

    public var displayBounds(get_displayBounds, null):Rectangle;

    public function new()
    {
        blendMode = BlendMode.NORMAL_A;

        onTransformChange = new Signal1<Node2D>();
        onWorldTransformChange = new Signal1<Node2D>();
        onColorTransformChange = new Signal1<Node2D>();

        children = new FastList<Node2D>();
        childrenUtils = new FastListUtils<Node2D>(children);
        transform = new Matrix3D();

        worldColorTransform = new Vector3D();
        worldTransform = new Matrix3D();
        invertWorldTransform = new Matrix3D();

        colorTransform = null;

        name = "node_" + uid++;
		
		bounds = new Rectangle();
		_boundRect2 = new Rectangle();
        displayBounds = new Rectangle();
    }

    public function dispose():Void
    {
        if (parent != null) parent.removeChild(this);

        onTransformChange.removeAll();
        onTransformChange = null;
        onWorldTransformChange.removeAll();
        onWorldTransformChange = null;
        onColorTransformChange.removeAll();
        onColorTransformChange = null;

        if (children != null)
            for (child in children) child.dispose();

        ctx = null;
        children = null;
        childrenUtils = null;
        transform = null;
        worldTransform = null;
        worldColorTransform = null;
        invertWorldTransform = null;
        blendMode = null;

        // TODO: replace with var o:Dynamic = this; o.onVisibleChange = null;
        if (Reflect.field(this, "onVisibleChange") != null)
        {
            onVisibleChange.removeAll();
            Reflect.setField(this, "onVisibleChange", null);
        }
        if (Reflect.field(this, "onMouseOver") != null)
        {
            onMouseOver.removeAll();
            Reflect.setField(this, "onMouseOver", null);
        }
        if (Reflect.field(this, "onMouseOut") != null)
        {
            onMouseOut.removeAll();
            Reflect.setField(this, "onMouseOut", null);
        }
        if (Reflect.field(this, "onMouseDown") != null)
        {
            onMouseDown.removeAll();
            Reflect.setField(this, "onMouseDown", null);
        }
        if (Reflect.field(this, "onMouseUp") != null)
        {
            onMouseUp.removeAll();
            Reflect.setField(this, "onMouseUp", null);
        }
        if (Reflect.field(this, "onWorld") != null)
        {
            onWorld.removeAll();
            Reflect.setField(this, "onWorld", null);
        }
        if (Reflect.field(this, "onScene") != null)
        {
            onScene.removeAll();
            Reflect.setField(this, "onScene", null);
        }

        Reflect.setField(this, "pivot", null);
        Reflect.setField(this, "colorTransform", null);
		
		bounds = null;
		_boundRect2 = null;
		displayBounds = null;
    }

    public function init(ctx:Context3D):Void
    {
        if (this.ctx != ctx)
        {
            this.ctx = ctx;
            if (children != null) for (i in children) i.init(ctx);
        }
    }

    function setParent(p:Node2D)
    {
        if (parent != null)
        {
            parent.onWorldTransformChange.remove(onParentTransformChange);
            parent.onColorTransformChange.remove(onParentColorChange);
        }

        parent = p;

        if (parent != null)
        {
            parent.onWorldTransformChange.add(onParentTransformChange);
            parent.onColorTransformChange.add(onParentColorChange);
        }

        onParentColorChange();
        onParentTransformChange();
    }

    function onParentColorChange(?_)
    {
        invalidateColorTransform = true;
        onColorTransformChange.dispatch(this);
    }

    function onParentTransformChange(?_)
    {
        invalidateBounds = true;
        invalidateWorldTransform = true;
        invalidateInvertWorldTransform = true;
        onWorldTransformChange.dispatch(this);
    }

    function setScene(s:Scene2D):Void
    {
        if (Reflect.hasField(this, "onScene")) onScene.dispatch(scene, scene = s);
        else scene = s;

        if (Reflect.hasField(this, "onWorld")) onWorld.dispatch(world, world = s != null ? s.world : null);
        else world = s != null ? s.world : null;

        if (children != null) for (i in children) i.setScene(s);
    }

    function setWorld(w:World2D):Void
    {
        if (Reflect.hasField(this, "onWorld")) onWorld.dispatch(world, world = w);
        else world = w;
        if (children != null) for (i in children) i.setWorld(w);
    }

    // children

    public function contains(c:Node2D):Bool
    {
        return c.parent == this;
    }

    public function getChildIndex(c:Node2D):Int
    {
        return childrenUtils.indexOf(c);
    }

    public function addChildAt(c:Node2D, pos:UInt):Void
    {
        #if debug
        if (pos > numChildren) throw "out of bounds";
        #end
        if (c.parent != null)
        {
            if (c.parent == this)
            {
                if (childrenUtils.tail.elt != c)
                {
                    childrenUtils.remove(c);
                    childrenUtils.push(c);
                }
                return;
            }

            c.parent.removeChild(c);
        }

        #if debug
        var p = parent;
        while (p != null)
        {
            if (p == c) throw "can't add parent node as child";
            p = p.parent;
        }
        #end

        childrenUtils.putAt(c, pos);
        numChildren = childrenUtils.length;

        c.setParent(this);
        if (scene != null) c.setScene(scene);
        if (ctx != null) c.init(ctx);

        invalidateBounds = true;
    }

    public function addChild(c:Node2D):Void
    {
        addChildAt(c, numChildren);
    }

    public function removeChildAt(pos:UInt)
    {
        #if debug
        if (pos >= numChildren) throw "out of bounds";
        #end

        removeChild(childrenUtils.getAt(pos));
    }

    public function removeChild(c:Node2D):Void
    {
        if (!childrenUtils.remove(c)) throw "c must be child";
        numChildren = childrenUtils.length;

        c.parent = null;
        c.setParent(null);
        c.setScene(null);

        invalidateBounds = true;
    }

    public function getChildAt(pos:UInt):Node2D
    {
        #if debug
        if (pos >= numChildren) throw "out of bounds";
        #end

        return childrenUtils.getAt(pos);
    }

    public function iterator():Iterator<Node2D>
    {
        return children.iterator();
    }

    // mouse

    function get_mouseX()
    {
        if (mouseX == mouseX) return mouseX;
        return world != null ? globalToLocal(world.mousePos).x : Math.NaN;
    }

    function get_mouseY()
    {
        if (mouseY == mouseY) return mouseY;
        return world != null ? globalToLocal(world.mousePos).y : Math.NaN;
    }

    function displayHitTest(pos:Vector3D, mouseHit = true)
    {
        return false;
    }

    public function mouseStep(pos:Vector3D, md:MouseData)
    {
        var res:Node2D = null;

        if (mouseEnabled && (mouseOver = displayHitTest(pos))) res = this;
        if (!mouseOver)
        {
            mouseX = Math.NaN;
            mouseY = Math.NaN;
        }

        if (mouseChildren && children != null && numChildren > 0)
            for (i in children)
            {
                var subRes = i.mouseStep(pos, md);
                if (subRes != null) res = subRes;
            }

        if (onTransformChange == null) res = null; // destrucred test
        mouseOver = mouseOver || res != null;

        if (mouseOver)
        {
            if (!oldMouseOver) onMouseOver.dispatch(this, md);
        }
        else
        {
            if (oldMouseOver) onMouseOut.dispatch(this, md);
        }

        if (res != null)
        {
            switch (md.type)
            {
                case MouseEvent.MOUSE_DOWN:
                    if (mouseOver)
                    {
                        mouseDown = true;
                        onMouseDown.dispatch(res, md);
//                        trace("mouse down " + res + " " + this);
                    }

                case MouseEvent.MOUSE_UP:
                    if (mouseDown)
                    {
                        mouseDown = false;
                        onMouseUp.dispatch(res, md);
//                        trace("mouse up " + res + " " + this);
                    }
            }
        }

        oldMouseOver = mouseOver;

        return res;
    }

    public function hitTest(x:Float, y:Float):Bool
    {
        if (!bounds.contains(x, y)) return false;

        return globalHitTest(localToGlobal(new Vector3D(x, y)));
    }

    function globalHitTest(pos:Vector3D):Bool
    {
        if (displayHitTest(pos, false)) return true;

        if (numChildren == 0 || children == null) return false;

        for (c in children) if (c.globalHitTest(pos)) return true;

        return false;
    }

    public function updateStep()
    {
        for (i in children) if (i.visible) i.updateStep();
    }

    // render

    public function drawStep(camera:Camera2D):Void
    {
        for (i in children) if (i.visible) i.drawStep(camera);
    }

    function get_worldTransform():Matrix3D
    {
        if (invalidateWorldTransform)
        {
            worldTransform.rawData = transform.rawData;
            if (parent != null) worldTransform.append(parent.worldTransform);

            invalidateWorldTransform = false;
        }
        return worldTransform;
    }

    function get_invertWorldTransform():Matrix3D
    {
        if (invalidateWorldTransform || invalidateInvertWorldTransform)
        {
            invertWorldTransform.rawData = worldTransform.rawData;
            invertWorldTransform.invert();

            invalidateInvertWorldTransform = false;
        }
        return invertWorldTransform;
    }

    // transform

    function get_transform():Matrix3D
    {
        if (invalidateTransform)
        {
            transform.identity();

            var moved = x != 0 || y != 0;
            var scaled = scaleX != 1 || scaleY != 1;

            if (usePivot) transform.appendTranslation(-pivot.x, -pivot.y, 0);
            if (scaled) transform.appendScale(scaleX, scaleY, 1);
            if (rotation != 0) transform.appendRotation(rotation, Vector3D.Z_AXIS);
            if (moved) transform.appendTranslation(x, y, 0);
            if (usePivot) transform.appendTranslation(pivot.x, pivot.y, 0);

            invalidateTransform = false;
        }

        return transform;
    }

    public var pivot(default, set_pivot):Point;
    public var usePivot(default, null):Bool;

    function set_pivot(v:Point):Point
    {
        if (v != null && v.x == 0 && v.y == 0) v = null;

        if (pivot == null || !v.equals(pivot))
        {
            pivot = v;
            usePivot = v != null;
            invalidateBounds = true;
            invalidateTransform = true;
            invalidateWorldTransform = true;
            onTransformChange.dispatch(this);
        }
        return v;
    }

    public var x(default, set_x):Float = 0;
    public var y(default, set_y):Float = 0;

    public var rotation(default, set_rotation):Float = 0;

    public var scaleX(default, set_scaleX):Float = 1;
    public var scaleY(default, set_scaleY):Float = 1;

    function set_x(v:Float)
    {
        if (x != v)
        {
            x = v;
            invalidateBounds = true;
            invalidateTransform = true;
            invalidateWorldTransform = true;
            onTransformChange.dispatch(this);
            onWorldTransformChange.dispatch(this);
        }
        return v;
    }

    function set_y(v:Float)
    {
        if (y != v)
        {
            y = v;
            invalidateBounds = true;
            invalidateTransform = true;
            invalidateWorldTransform = true;
            onTransformChange.dispatch(this);
            onWorldTransformChange.dispatch(this);
        }
        return v;
    }

    function set_rotation(v:Float)
    {
        if (rotation != v)
        {
            while (rotation < -Math.PI) rotation += 2 * Math.PI;
            while (rotation > Math.PI) rotation -= 2 * Math.PI;
            rotation = v;
            invalidateBounds = true;
            invalidateTransform = true;
            invalidateWorldTransform = true;
            onTransformChange.dispatch(this);
            onWorldTransformChange.dispatch(this);
        }
        return v;
    }

    function set_scaleX(v:Float)
    {
        if (scaleX != v)
        {
            scaleX = v;
            invalidateBounds = true;
            invalidateTransform = true;
            invalidateWorldTransform = true;
            onTransformChange.dispatch(this);
            onWorldTransformChange.dispatch(this);
        }
        return v;
    }

    function set_scaleY(v:Float)
    {
        if (scaleY != v)
        {
            scaleY = v;
            invalidateBounds = true;
            invalidateTransform = true;
            invalidateWorldTransform = true;
            onTransformChange.dispatch(this);
            onWorldTransformChange.dispatch(this);
        }
        return v;
    }

    // color transform

    function get_worldColorTransform()
    {
        if (invalidateColorTransform)
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
        }

        return worldColorTransform;
    }

    function set_colorTransform(c)
    {
        if (c == null) c = new Color(1, 1, 1, 1);

        if (colorTransform == null || !c.equals(colorTransform))
        {
            colorTransform = c;
            alpha = c.a;
            invalidateColorTransform = true;
            onColorTransformChange.dispatch(this);
        }

        return c;
    }

    function set_alpha(v:Float):Float
    {
        v = Color.clamp(v);
        if (v != alpha)
        {
            alpha = colorTransform.a = v;
            invalidateColorTransform = true;
            onColorTransformChange.dispatch(this);
        }
        return v;
    }

	function get_displayBounds():Rectangle
	{
		return displayBounds;
	}

	function get_bounds():Rectangle
	{
        if (invalidateBounds)
        {
            bounds.copyFrom(displayBounds);

            if (numChildren == 0) return bounds;

            for (c in children)
            {
                if (!c.visible) continue;
                c.getBounds(this, _boundRect2);

                if (!_boundRect2.isEmpty())
                {
                    if (bounds.isEmpty())
                    {
                        bounds.x = _boundRect2.x;
                        bounds.y = _boundRect2.y;
                        bounds.width = _boundRect2.width;
                        bounds.height = _boundRect2.height;
                    }
                    else
                    {
                        var x0:Float = (bounds.x > _boundRect2.x) ? _boundRect2.x : bounds.x;
                        var y0:Float = (bounds.y > _boundRect2.y) ? _boundRect2.y : bounds.y;
                        var x1:Float = (bounds.right < _boundRect2.right) ? _boundRect2.right : bounds.right;
                        var y1:Float = (bounds.bottom < _boundRect2.bottom) ? _boundRect2.bottom : bounds.bottom;
                        bounds.x = x0;
                        bounds.y = y0;
                        bounds.width = x1 - x0;
                        bounds.height = y1 - y0;
                    }
                }
            }
            invalidateBounds = false;
        }

		return bounds;
	}

    static var p1:Vector3D = new Vector3D();
    static var p2:Vector3D = new Vector3D();
    static var p3:Vector3D = new Vector3D();
    static var p4:Vector3D = new Vector3D();

    public function getBounds(target:Node2D, boundRect:Rectangle = null):Rectangle
    {
        if (boundRect == null) boundRect = new Rectangle();

        boundRect.copyFrom(displayBounds);

        var m:Matrix3D = target.invertWorldTransform.clone();
        m.prepend(worldTransform);

        if (!boundRect.isEmpty())
        {
            p1.setTo(boundRect.x, boundRect.y, 0);
            p2.setTo(boundRect.x, boundRect.bottom, 0);
            p3.setTo(boundRect.right, boundRect.y, 0);
            p4.setTo(boundRect.right, boundRect.bottom, 0);
            p1 = m.transformVector(p1);
            p2 = m.transformVector(p2);
            p3 = m.transformVector(p3);
            p4 = m.transformVector(p4);

            boundRect.x = Math.min(p1.x, Math.min(p2.x, Math.min(p3.x, p4.x)));
            boundRect.right = Math.max(p1.x, Math.max(p2.x, Math.max(p3.x, p4.x)));
            boundRect.y = Math.min(p1.y, Math.min(p2.y, Math.min(p3.y, p4.y)));
            boundRect.bottom = Math.max(p1.y, Math.max(p2.y, Math.max(p3.y, p4.y)));
        }
        else
        {
            p1.setTo(boundRect.x, boundRect.y, 0);
            p1 = m.transformVector(p1);
            boundRect.x = p1.x;
            boundRect.y = p1.y;
        }

        if (numChildren == 0) return boundRect;

        for (c in children)
        {
            if (!c.visible) continue;
            c.getBounds(target, _boundRect2);

            if (!_boundRect2.isEmpty())
            {
                if (boundRect.isEmpty())
                {
                    boundRect.x = _boundRect2.x;
                    boundRect.y = _boundRect2.y;
                    boundRect.width = _boundRect2.width;
                    boundRect.height = _boundRect2.height;
                }
                else
                {
                    var x0:Float = (boundRect.x > _boundRect2.x) ? _boundRect2.x : boundRect.x;
                    var y0:Float = (boundRect.y > _boundRect2.y) ? _boundRect2.y : boundRect.y;
                    var x1:Float = (boundRect.right < _boundRect2.right) ? _boundRect2.right : boundRect.right;
                    var y1:Float = (boundRect.bottom < _boundRect2.bottom) ? _boundRect2.bottom : boundRect.bottom;
                    boundRect.x = x0;
                    boundRect.y = y0;
                    boundRect.width = x1 - x0;
                    boundRect.height = y1 - y0;
                }
            }
        }

        return boundRect;
    }

    public inline function localToGlobal(v:Vector3D):Vector3D
    {
        return worldTransform.transformVector(v);
    }

    public inline function globalToLocal(v:Vector3D):Vector3D
    {
        return invertWorldTransform.transformVector(v);
    }

	public var width(get_width, set_width):Float;
	
	private function get_width():Float
	{
		return bounds.width * scaleX;
	}

    function set_width(v:Float):Float
    {
        var w = width;
        if (w != 0)
        {
            scaleX = v / (w / scaleX);
            return v;
        }
        return 0;
    }
	
	public var height(get_height, set_height):Float;
	
	private function get_height():Float
	{
		return bounds.height * scaleY;
	}

    function set_height(v:Float):Float
    {
        var h = height;
        if (h != 0)
        {
            scaleY = v / (h / scaleY);
            return v;
        }
        return 0;
    }

    public function toString()
    {
        var ref = Type.getClassName(Type.getClass(this)).split(".").pop();

        return Std.format("{$ref: $name, visible:$visible}");
    }
}