package
{

import flash.display.MovieClip;

[SWF(frameRate="60")]
public class AirWrapper extends MovieClip
{

    [Embed(source="../../particle_explorer/bin/app.swf")]
    private var swf:Class;

    public function AirWrapper()
    {
        addChild(new swf());
    }
}
}
