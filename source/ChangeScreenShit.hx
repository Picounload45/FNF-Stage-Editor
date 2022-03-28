/* UHH THIS SHIT IS NOT WORKING
package;

import flixel.*;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class ChangeScreenShit
{
    public static function changeState(state:FlxState, changeType:String, ?cameraSHIT:FlxCamera)
    {
        var blackThing:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        blackThing.alpha = 0;
        if (cameraSHIT != null) blackThing.cameras = [cameraSHIT];
        switch (changeType)
        {
            case 'Fade In-Out':
                FlxTween.tween(blackThing, {alpha: 1}, 1, {onComplete: function(twn:FlxTween)
                    {
                        FlxG.switchState(state);
                        if (FlxG.state.switchTo(state))
                            FlxTween.tween(blackThing, {alpha: 0}, 1);
                    }
                });
        }
    }

    public static function changeSubState(state:FlxSubState, changeType:String, ?cameraSHIT:FlxCamera)
    {
        var blackThing:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        blackThing.alpha = 0;
        if (cameraSHIT != null) blackThing.cameras = [cameraSHIT];
        switch (changeType)
        {
            case 'Fade In-Out':
                FlxTween.tween(blackThing, {alpha: 1}, 1, {onComplete: function(twn:FlxTween)
                    {
                        FlxG.state.openSubState(state);
                        if (FlxG.state.switchTo(state))
                            FlxTween.tween(blackThing, {alpha: 0}, 1);
                    }
                });
        }
    }
}*/