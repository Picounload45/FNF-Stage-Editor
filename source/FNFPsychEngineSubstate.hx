package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

class FNFPsychEngineSubstate extends FlxSubState
{
    var healthBarBG:FlxSprite;
    var healthBar:FlxBar;
    var iconP1:FlxSprite;
    var iconP2:FlxSprite;
    var bfOffset:Float = 25;
    var dadOffset:Float = 25;
    var health:Float = 1;
    var scoreTxt:FlxText;
    var strumLineNotes:FlxTypedGroup<FlxSprite>;
    var leak:PlayState;
    private var camHUD:FlxCamera;
    var timeBar:FlxBar;
    var timeTxt:FlxText;
    var timeBarBG:FlxSprite;
    var time:Float = 0;

    public function new(x:Float, y:Float, yas:FlxCamera)
    {
        camHUD = yas;
        super();
        
        healthBarBG = new FlxSprite().loadGraphic('assets/images/healthBar.png');
        healthBarBG.screenCenter(X);
        healthBarBG.y = (FlxG.height - healthBarBG.height) / 1.1;
        healthBarBG.antialiasing = true;
        healthBarBG.cameras = [yas];
        add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, LEFT_TO_RIGHT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this, "health", 0, 2);
        healthBar.createFilledBar(0xFF31B0D1, 0xFFAF66CE);
        healthBar.cameras = [yas];
        add(healthBar);

        scoreTxt = new FlxText(0, healthBarBG.y + 60, 0,"Score: 0 | Misses: 0 | Rating: ?", 32);
        scoreTxt.screenCenter(X);
        add(scoreTxt);

        timeBarBG = new FlxSprite(0, 30, 'assets/images/timeBar.png');
        timeBarBG.cameras = [yas];
        timeBarBG.antialiasing = true;
        add(timeBarBG);

        timeBar = new FlxBar(0, 30, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 7), Std.int(timeBarBG.width - 7), this, "", 0, 100);
        timeBar.cameras = [yas];
        timeBar.screenCenter(X);
        add(timeBar);

        timeTxt = new FlxText(0, 0, 0, "2:00", 16);
        timeTxt.x = (timeBar.width / 2) - (timeTxt.width / 2);
        timeTxt.y = timeBar.y;
        add(timeTxt);

        iconP1 = new FlxSprite(healthBar.pxPerPercent + bfOffset, healthBar.y - 75).loadGraphic('assets/images/icons/bf.png', true, 150, 150);
        iconP1.animation.add('bf',[0,1],0,false,true);
        iconP1.animation.play('bf');
        iconP1.cameras = [yas];

        iconP2 = new FlxSprite(0, healthBar.y - 75).loadGraphic('assets/images/icons/dad.png', true, 150, 150);
        iconP2.animation.add('dad',[0,1],0,false,false);
        iconP2.animation.play('dad');
        iconP2.x = (iconP1.x - iconP2.width) - dadOffset;
        iconP2.cameras = [yas];

        add(iconP1); add(iconP2);

        var kadebt:FlxButton = new FlxButton(0, 40, "Change To KE", function()
        {
            loadKadeEngine();
        });
        kadebt.x = (FlxG.width - kadebt.width) / 1.2;

        var psychbt:FlxButton = new FlxButton(kadebt.x, kadebt.y + 20, "Change To PE", function()
        {
            loadPsychEngine();
        });

        add(psychbt);
        add(kadebt);

        createArrows(0);
        createArrows(1);
    }

    var yeahTime:Float = 0;

    override function update(yeah:Float)
    {
        iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - bfOffset);
        iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - dadOffset);

        yeahTime += yeah;

        health += Math.cos(yeahTime * 2) * 1.1;
        
        if (FlxG.keys.justPressed.ESCAPE)
        {
            closeSubState();
        }

        super.update(yeah);
    }

    override function closeSubState()
    {
        for (i in [iconP1, iconP2, healthBar, healthBarBG, strumLineNotes])
        {
            remove(i);
        }
        leak.helpTxt.visible = true;
        leak.box.visible = true;
        leak.positionTxt.visible = true;
        
        super.closeSubState();
    }

    var kadeEngine:Bool = false;

    function createArrows(player:Int)
    {
        strumLineNotes = new FlxTypedGroup<FlxSprite>();
        strumLineNotes.cameras = [camHUD];
        add(strumLineNotes);
        
        for (i in 0...4)
        {
            var babyArrow:FlxSprite = new FlxSprite(kadeEngine ? 0 : 85, 50);
            
		    babyArrow.frames = FlxAtlasFrames.fromSparrow('assets/images/NOTE_assets.png', 'assets/images/NOTE_assets.xml');
			babyArrow.animation.addByPrefix('green', 'arrowUP');
			babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
			babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
			babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

			babyArrow.antialiasing = true;
			babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

			switch (Math.abs(i))
			{
				case 0:
					babyArrow.animation.addByPrefix('static', 'arrowLEFT');
					babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
				case 1:
					babyArrow.animation.addByPrefix('static', 'arrowDOWN');
					babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
		    		babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
				case 2:
					babyArrow.animation.addByPrefix('static', 'arrowUP');
					babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
				case 3:
					babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
				    babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
			}
			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			babyArrow.ID = i;

			babyArrow.animation.play('static');
            babyArrow.x += 112 * i;
			babyArrow.x += 50;
            babyArrow.x += (FlxG.width / 2) * player;
            strumLineNotes.add(babyArrow);
        }
    }

    function loadKadeEngine()
    {
        kadeEngine = true;
        remove(strumLineNotes);
        createArrows(0);
        createArrows(1);
        timeTxt.visible = false;
        timeBar.visible = true;
        scoreTxt.text = 'Score: 0';
        scoreTxt.size = 16;
        healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, LEFT_TO_RIGHT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this, "health", 0, 2);
        healthBar.createFilledBar(FlxColor.RED, FlxColor.LIME);
        iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - bfOffset);
        iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - dadOffset);
    }

    function loadPsychEngine()
    {
        kadeEngine = false;
        remove(strumLineNotes);
        createArrows(0);
        createArrows(1);
            timeTxt.visible = true;
            timeBar.visible = true;
            scoreTxt.text = 'Score: 0 | Misses: 0 | Rating: ?';
            scoreTxt.size = 32;
            healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, LEFT_TO_RIGHT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this, "health", 0, 2);
            healthBar.createFilledBar(0xFF31B0D1, 0xFFAF66CE);
            health = 1;
            iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - bfOffset);
            iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - dadOffset);
    }
}