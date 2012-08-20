package mt.m3d;
// use left-handed coordinate system, more suitable for 2D games X=0,Y=0 at screen top-left and Z towards user

class Camera {

    public var zoom : Float;
    public var ratio : Float;
    public var fov : Float;
    public var zNear : Float;
    public var zFar : Float;

    public var mprojPer : Matrix;
    public var mprojOrt : Matrix;
    public var mcam : Matrix;
    public var mProj : Matrix;
    public var mOrt : Matrix;

    public var pos : Vector;
    public var up : Vector;
    public var target : Vector;

    public var w:Int;
    public var h:Int;

    public function new( fov = 60., zoom = 1., ratio = 1.333333, zNear = 0.02, zFar = 40. ) {
        this.fov = fov;
        this.zoom = zoom;
        this.ratio = ratio;
        this.zNear = zNear;
        this.zFar = zFar;
        pos = new Vector(2, 3, 4);
        up = new Vector(0, 0, -1);
        target = new Vector(0, 0, 0);
        mProj = new Matrix();
        mOrt = new Matrix();
        mcam = new Matrix();
        update();
    }

    public function update() {
        var az = pos.sub(target);
        az.normalize();
        var ax = up.cross(az);
        ax.normalize();
        if( ax.length() == 0 ) {
            ax.x = az.y;
            ax.y = az.z;
            ax.z = az.x;
        }
        var ay = az.cross(ax);
        mcam._11 = ax.x;
        mcam._12 = ay.x;
        mcam._13 = az.x;
        mcam._14 = 0;
        mcam._21 = ax.y;
        mcam._22 = ay.y;
        mcam._23 = az.y;
        mcam._24 = 0;
        mcam._31 = ax.z;
        mcam._32 = ay.z;
        mcam._33 = az.z;
        mcam._34 = 0;
        mcam._41 = -ax.dot(pos);
        mcam._42 = -ay.dot(pos);
        mcam._43 = -az.dot(pos);
        mcam._44 = 1;

        mprojPer = makeFrustumMatrix();
        mProj.multiply4x4(mcam, mprojPer);
        mprojOrt = makeOrtographicMatrix();
        mOrt.multiply4x4(mcam, mprojOrt);
    }

    public function moveAxis( dx : Float, dy : Float ) {
        var p = new Vector(dx, dy, 0);
        p.project3x3(mcam);
        pos.x += p.x;
        pos.y += p.y;
        pos.z += p.z;
    }

    function makeOrtographicMatrix():Matrix
    {
        var m:Matrix = new Matrix();
        m.zero();
        m._11 = 2 / w;
        m._22 = -2 / h;
        m._33 = 1 / (zNear - zFar);
        m._43 = zNear / (zNear - zFar);
        m._44 = 1;

        return m;
    }

    function makeFrustumMatrix() {
        var scale = zoom / Math.tan(fov * Math.PI / 360.0);
        var m = new Matrix();
        m.zero();
        m._11 = scale;
        m._22 = -scale * ratio;
        m._33 = zFar / (zNear - zFar);
        m._34 = -1;
        m._43 = (zNear * zFar) / (zNear - zFar);

        return m;
    }
	
	public function dispose():Void
	{
		mprojOrt = null;
		mprojPer = null;
		mcam = null;
		mProj = null;
		mOrt = null;
		pos = null;
		up = null;
		target = null;
	}

}
