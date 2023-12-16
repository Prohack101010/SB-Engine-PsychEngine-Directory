package animateatlas;


import openfl.geom.Rectangle;



import openfl.Assets;
import haxe.Json;
import openfl.display.BitmapData;
import animateatlas.JSONData.AtlasData;
import animateatlas.JSONData.AnimationData;
import animateatlas.displayobject.SpriteAnimationLibrary;
import animateatlas.displayobject.SpriteMovieClip;

import flixel.graphics.frames.FlxFramesCollection;
import flixel.graphics.frames.FlxFrame;





using StringTools;
class AtlasFrameMaker extends FlxFramesCollection
{
	//public static var widthoffset:Int = 0;
	//public static var heightoffset:Int = 0;
	//public static var excludeArray:Array<String>;
	/**
	
	* Creates Frames from TextureAtlas(very early and broken ok) Originally made for FNF HD by Smokey and Rozebud
	*
	* @param   key                 The file path.
	* @param   _excludeArray       Use this to only create selected animations. Keep null to create all of them.
	*
	*/

	public static function construct(key:String,?_excludeArray:Array<String> = null, ?noAntialiasing:Bool = false):FlxFramesCollection
	{
		// widthoffset = _widthoffset;
		// heightoffset = _heightoffset;

		var frameCollection:FlxFramesCollection;
		var frameArray:Array<Array<FlxFrame>> = [];

		if (Paths.fileExists('images/$key/spritemap1.json', TEXT))
		{
			PlayState.instance.addTextToDebug("Only Spritemaps made with Adobe Animate 2018 are supported", FlxColor.RED);
			trace("Only Spritemaps made with Adobe Animate 2018 are supported");
			return null;
		}

		var animationData:AnimationData = Json.parse(Paths.getTextFromFile('images/$key/Animation.json'));
		var atlasData:AtlasData = Json.parse(Paths.getTextFromFile('images/$key/spritemap.json').replace("\uFEFF", ""));

		var graphic:FlxGraphic = Paths.image('$key/spritemap');
		var ss:SpriteAnimationLibrary = new SpriteAnimationLibrary(animationData, atlasData, graphic.bitmap);
		var t:SpriteMovieClip = ss.createAnimation(noAntialiasing);
		if(_excludeArray == null)
		{
			_excludeArray = t.getFrameLabels();
			//trace('creating all anims');
		}
		trace('Creating: ' + _excludeArray);

		frameCollection = new FlxFramesCollection(graphic, FlxFrameCollectionType.IMAGE);
		for(x in _excludeArray)
		{
			frameArray.push(getFramesArray(t, x));
		}

		for(x in frameArray)
		{
			for(y in x)
			{
				frameCollection.pushFrame(y);
			}
		}
		return frameCollection;
	}

	@:noCompletion static function getFramesArray(t:SpriteMovieClip,animation:String):Array<FlxFrame>
	{
		var sizeInfo:Rectangle = new Rectangle(0, 0);
		t.currentLabel = animation;
		var bitmapArray:Array<BitmapData> = [];
		var frameValue:Array<FlxFrame> = [];
		var firstPass = true;
		var frameSize:FlxPoint = new FlxPoint(0, 0);

		for (i in t.getFrame(animation)...t.numFrames)
			{
				t.currentFrame = i;
				if (t.currentLabel == animation)
				{
					sizeInfo = t.getBounds(t);
					var bitmapValue:BitmapData = new BitmapData(Std.int(sizeInfo.width + sizeInfo.x), Std.int(sizeInfo.height + sizeInfo.y), true, 0);
					if (ClientPrefs.gpuCaching)
					{
						var texture:openfl.display3D.textures.RectangleTexture = FlxG.stage.context3D.createRectangleTexture(bitmapValue.width, bitmapValue.height, BGRA, true);
						texture.uploadFromBitmapData(bitmapValue);
						bitmapValue.image.data = null;
						bitmapValue.dispose();
						bitmapValue.disposeImage();
						bitmapValue = BitmapData.fromTexture(texture);
					}
					bitmapValue.draw(t, null, null, null, null, true);
					bitmapArray.push(bitmapValue);
	
					if (firstPass)
					{
						frameSize.set(bitmapValue.width,bitmapValue.height);
						firstPass = false;
					}
				}
				else break;
			}
			
			for (i in 0...bitmapArray.length)
			{
				var b = FlxGraphic.fromBitmapData(bitmapArray[i]);
				var theFrame = new FlxFrame(b);
				theFrame.parent = b;
				theFrame.name = animation + i;
				theFrame.sourceSize.set(frameSize.x,frameSize.y);
				theFrame.frame = new FlxRect(0, 0, bitmapArray[i].width, bitmapArray[i].height);
				frameValue.push(theFrame);
				//trace(frameValue);
			}
			return frameValue;
		}
	}