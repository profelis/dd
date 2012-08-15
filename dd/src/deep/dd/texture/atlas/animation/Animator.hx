package deep.dd.texture.atlas.animation;

import deep.dd.texture.atlas.AtlasTexture2D;
import deep.dd.display.MovieClip2D;
import deep.dd.display.Sprite2D;

class Animator
{
    public var sprite:Sprite2D;

    public var fps:UInt = 30;

    var frameTime:Float = 0;
    var currentFrame:Int = -1;

    var prevTime:Float = 0;

    public function new(fps:UInt = 30)
    {
        this.fps = fps;
    }

    public function draw(time:Float)
    {
        frameTime += fps * (time - prevTime);
        prevTime = time;
        if (frameTime > 1)
        {
            frameTime = 0;
            currentFrame++;

            var atlas = cast(sprite.texture, AtlasTexture2D);
            atlas.frame = atlas.frames[currentFrame % atlas.frames.length];
        }
    }

    public function dispose()
    {
        sprite = null;
    }
}
