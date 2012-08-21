package deep.dd.texture.atlas.parser;

import deep.dd.texture.Frame;
import deep.dd.texture.Texture2D;
import flash.geom.Rectangle;
import flash.geom.Point;
import deep.dd.texture.atlas.AtlasTexture2D;
import deep.dd.texture.atlas.FontAtlasTexture2D;
import flash.geom.Vector3D;

class FontSheetParser implements IAtlasParser
{
    /**
	 * Text Set 1 = !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~
	 */
	public static inline var TEXT_SET1:String = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~";
	
	/**
	 * Text Set 2 =  !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ
	 */
	public static inline var TEXT_SET2:String = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	
	/**
	 * Text Set 3 = ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 
	 */
	public static inline var TEXT_SET3:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 ";
	
	/**
	 * Text Set 4 = ABCDEFGHIJKLMNOPQRSTUVWXYZ 0123456789
	 */
	public static inline var TEXT_SET4:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ 0123456789";
	
	/**
	 * Text Set 5 = ABCDEFGHIJKLMNOPQRSTUVWXYZ.,/() '!?-*:0123456789
	 */
	public static inline var TEXT_SET5:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ.,/() '!?-*:0123456789";
	
	/**
	 * Text Set 6 = ABCDEFGHIJKLMNOPQRSTUVWXYZ!?:;0123456789\"(),-.' 
	 */
	public static inline var TEXT_SET6:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ!?:;0123456789\"(),-.' ";
	
	/**
	 * Text Set 7 = AGMSY+:4BHNTZ!;5CIOU.?06DJPV,(17EKQW\")28FLRX-'39
	 */
	public static inline var TEXT_SET7:String = "AGMSY+:4BHNTZ!;5CIOU.?06DJPV,(17EKQW\")28FLRX-'39";
	
	/**
	 * Text Set 8 = 0123456789 .ABCDEFGHIJKLMNOPQRSTUVWXYZ
	 */
	public static inline var TEXT_SET8:String = "0123456789 .ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	
	/**
	 * Text Set 9 = ABCDEFGHIJKLMNOPQRSTUVWXYZ()-0123456789.:,'\"?!
	 */
	public static inline var TEXT_SET9:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ()-0123456789.:,'\"?!";
	
	/**
	 * Text Set 10 = ABCDEFGHIJKLMNOPQRSTUVWXYZ
	 */
	public static inline var TEXT_SET10:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	
	/**
	 * Text Set 11 = ABCDEFGHIJKLMNOPQRSTUVWXYZ.,\"-+!?()':;0123456789
	 */
	public static inline var TEXT_SET11:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ.,\"-+!?()':;0123456789";
	
	/**
	 * If the font set doesn't start at the top left of the given image, specify the X coordinate offset here.
	 */
	var offsetX:UInt;
	
	/**
	 * If the font set doesn't start at the top left of the given image, specify the Y coordinate offset here.
	 */
	var offsetY:UInt;
	
	/**
	 * The width of each character in the font set.
	 */
	public var characterWidth:UInt;
	/**
	 * The height of each character in the font set.
	 */
	public var characterHeight:UInt;
	
	/**
	 * If the characters in the font set have horizontal spacing between them set the required amount here.
	 */
	var characterSpacingX:UInt;
	
	/**
	 * If the characters in the font set have vertical spacing between them set the required amount here
	 */
	var characterSpacingY:UInt;
	
	/**
	 * The number of characters per row in the font set.
	 */
	var characterPerRow:UInt;
	
	/**
	 * The characters used in the font set, in display order.
	 */
	var charsSet:String;
	
	var padding:Float;
	
	/**
	 * Parser's constructor. Prepares it for loading font sheet some later.
	 * @param	charWidth	The width of each character in the font set.
	 * @param	charHeight	The height of each character in the font set.
	 * @param	chars	The characters used in the font set, in display order. You can use the TEXT_SET consts for common font set arrangements.
	 * @param	charsPerRow	The number of characters per row in the font set.
	 * @param	xSpacing	If the characters in the font set have horizontal spacing between them set the required amount here.
	 * @param	ySpacing	If the characters in the font set have vertical spacing between them set the required amount here
	 * @param	xOffset	If the font set doesn't start at the top left of the given image, specify the X coordinate offset here.
	 * @param	yOffset	If the font set doesn't start at the top left of the given image, specify the Y coordinate offset here.
	 */
    public function new(charWidth:UInt, charHeight:UInt, chars:String, charsPerRow:UInt, padding:Float = 0.0, xSpacing:UInt = 0, ySpacing:UInt = 0, xOffset:UInt = 0, yOffset:UInt = 0)
    {
        characterWidth = charWidth;
		characterHeight = charHeight;
		charsSet = chars;
		characterPerRow = charsPerRow;
		characterSpacingX = xSpacing;
		characterSpacingY = ySpacing;
		offsetX = xOffset;
		offsetY = yOffset;
		this.padding = padding;
    }

    public function parse(a:AtlasTexture2D):Array<Frame>
    {
        var frames:Array<Frame> = [];

        var kx = 1 / a.textureWidth;
        var ky = 1 / a.textureHeight;

		var currentX:Int = offsetX;
		var currentY:Int = offsetY;
		var r:UInt = 0;
		
		var w = characterWidth - padding * 2;
        var h = characterHeight - padding * 2;
		
		var rw = w * kx;
        var rh = h * ky;

        frames = new Array();
		
		var border:Rectangle = padding > 0 ? new Rectangle(padding, padding, characterWidth, characterHeight) : null;
		
		for (c in 0...(charsSet.length))
		{
			frames.push(new Frame(w, h, new Vector3D((currentX + padding) * kx, (currentY + padding) * ky, rw, rh), border, charsSet.charAt(c)));
			r++;
			
			if (r == characterPerRow)
			{
				r = 0;
				currentX = offsetX;
				currentY += characterHeight + characterSpacingY;
			}
			else
			{
				currentX += characterWidth + characterSpacingX;
			}
		}
		
		cast(a, FontAtlasTexture2D).spaceWidth = characterWidth;
		
        return frames;
    }
}
