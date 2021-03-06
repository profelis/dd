package deep.dd.material.radialParticle2D;

import deep.dd.display.smart.SmartSprite2D;
import deep.dd.display.particle.ParticleSystem2D;
import deep.dd.utils.Frame;
import flash.Vector;
import deep.dd.display.DisplayNode2D;
import flash.geom.Vector3D;
import flash.geom.Matrix3D;
import deep.dd.material.sprite2d.Sprite2DMaterial;
import deep.dd.texture.Texture2D;
import deep.dd.material.Material;
import deep.dd.display.Sprite2D;
import deep.dd.camera.Camera2D;
import deep.dd.display.DisplayNode2D;
import deep.dd.material.Quad2DMaterial;
import deep.dd.utils.FastHaxe;
import flash.display3D.Context3D;
import hxsl.Shader;

class RadialParticle2DMaterial extends Material
{
    public function new()
    {
        super(null);
        texSize = new Vector3D();
    }

    var texSize:Vector3D;

    public function drawParticleSystem(node:SmartSprite2D, camera:Camera2D, renderSize:UInt)
    {
        var tex = node.texture;

        if (texOpt != tex.options)
        {
            texOpt = tex.options;
            updateShaderRef();
            attachShader();
        }

        texSize.x = tex.width;
        texSize.y = tex.height;

        untyped shader.init({time:node.scene.time, mproj:camera.proj, mpos:node.drawTransform, region:tex.frame.region, texSize:texSize, pcTrans:node.worldColorTransform}, {tex:tex.texture});

        #if dd_stat
        node.world.statistics.drawCalls ++;
        node.world.statistics.triangles += renderSize * 2;
        #end

        ctx.setBlendFactors(node.blendMode.src, node.blendMode.dst);

        shader.bind(ctx, node.geometry.vbuf);
        ctx.drawTriangles(node.geometry.ibuf, 0, renderSize * 2);
        shader.unbind(ctx);
    }

    override public function draw(node:DisplayNode2D, camera:Camera2D)
    {
        throw "use drawCloud";
    }
}