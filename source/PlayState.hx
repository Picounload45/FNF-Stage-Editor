package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import lime.system.System;
import sys.FileSystem;
import sys.io.File;

using StringTools;

class PlayState extends FlxState
{
	var box:FlxUITabMenu;
	var box_groups = [
		{name: "Assets", label: "Stage Assets"},
		{name: "Settings", label: "Stage Settings"}
	];
	var stageGrp:FlxTypedGroup<FlxSprite>;
	var camHUD:FlxCamera;
	var camStage:FlxCamera;
	var spriteNames:Array<String> = [];
	var positionTxt:FlxText;
	var defaultCamZoom:Float = 1.08;
	var helpTxt:FlxText;
	var useAnimation:Bool = false;
	var animations = [];
	var bg:FlxSprite;

	override function create()
	{
		camStage = new FlxCamera();
		camHUD = new FlxCamera();

		FlxG.cameras.reset(camStage);
		FlxG.cameras.add(camHUD);
		camHUD.bgColor.alpha = 0;
		FlxCamera.defaultCameras = [camStage];

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		box = new FlxUITabMenu(null, box_groups, true);
		box.resize(500, 350);
		box.x = 0;
		box.alpha = 0.8;
		box.screenCenter(Y);
		box.cameras = [camHUD];
		add(box);

		positionTxt = new FlxText(10, 10, 0, "Currect Selected Stage X/Y ScrollFactor X/Y:", 16);
		positionTxt.cameras = [camHUD];
		positionTxt.color = FlxColor.RED;
		add(positionTxt);

		helpTxt = new FlxText(box.x + 10, box.y + 350 + 10, 0, "Arrow Keys - Move Image\nwith Shift - Move Fast\nwith Ctrl - Move Slow", 16);
		helpTxt.cameras = [camHUD];
		add(helpTxt);

		createTabMenu('Stage Assets');
		createTabMenu('Stage Settings');

		super.create();
	}

	var alphaLine:Float = 0;
	var curSelected:Int = 0;
	var toMove:Float = 1;
	var blockControlOnTyping:FlxTypedGroup<FlxUIInputText>;

	override function update(elapsed:Float)
	{
		alphaLine += elapsed;

		if (defaultZoomInput != null)
		{
			if (defaultZoomInput.text == '')
				defaultZoomInput.text = '1.08';
			defaultCamZoom = Std.parseFloat(defaultZoomInput.text);
			var lerp:Float = FlxMath.lerp(defaultCamZoom,camStage.zoom,0.9);
			camStage.zoom=lerp;
		}

		var blockInput:Bool = false;
		if (stageGrp != null && stageGrp.length > 0 && stageGrp.members[Std.int(stageNumStepper.value)] != null)
		{
			positionTxt.text = 'Currect Selected Stage X/Y ScrollFactor X/Y:' +
				'\nX: ' + stageGrp.members[Std.int(stageNumStepper.value)].x +
				'\nY: ' + stageGrp.members[Std.int(stageNumStepper.value)].y +
				'\nScrollX: ' + stageGrp.members[Std.int(stageNumStepper.value)].scrollFactor.x +
				'\nScrollY: ' + stageGrp.members[Std.int(stageNumStepper.value)].scrollFactor.y;

			for (i in 0...stageGrp.length)
			{
				stageGrp.members[i].color = FlxColor.WHITE;
			}
			stageGrp.members[Std.int(stageNumStepper.value)].color = FlxColor.BLUE;
			if (!blockInput)
			{
				if (FlxG.keys.pressed.LEFT) stageGrp.members[Std.int(stageNumStepper.value)].x -= toMove;
				if (FlxG.keys.pressed.RIGHT) stageGrp.members[Std.int(stageNumStepper.value)].x += toMove;
				if (FlxG.keys.pressed.UP) stageGrp.members[Std.int(stageNumStepper.value)].y -= toMove;
				if (FlxG.keys.pressed.DOWN) stageGrp.members[Std.int(stageNumStepper.value)].y += toMove;

				if (FlxG.keys.pressed.SHIFT) toMove = 5;
				if (FlxG.keys.pressed.CONTROL) toMove = 0.5;
				if (FlxG.keys.justReleased.SHIFT || FlxG.keys.justReleased.CONTROL) toMove = 1;
			}
		} else {
			for (i in 0...stageGrp.length)
			{
				stageGrp.members[i].color = FlxColor.WHITE;
			}
			positionTxt.text = 'Currect Selected Stage X/Y ScrollFactor X/Y: Null';
		}

		for (i in 0...blockControlOnTyping.length)
		{
			blockControlOnTyping.members[i].callback = function(text:String, action:String)
			{
				if (!blockInput && blockControlOnTyping.members[i].hasFocus)
				{
					FlxG.sound.volumeUpKeys = [];
					FlxG.sound.muteKeys = [];
					FlxG.sound.volumeDownKeys = [];
					blockInput = true;
				}
				if (!blockControlOnTyping.members[i].hasFocus)
				{
					FlxG.sound.volumeUpKeys = [PLUS, NUMPADPLUS];
					FlxG.sound.muteKeys = [ZERO, NUMPADZERO];
					FlxG.sound.volumeDownKeys = [MINUS, NUMPADMINUS];
					blockInput = false;
				}
			}
		}
		
		if (usinAnimation_CB != null)
			useAnimation = usinAnimation_CB.checked;

		super.update(elapsed);
	}

	var stageNumStepper:FlxUINumericStepper;
	var stageNumStepper2:FlxUINumericStepper;
	var scrollXInput:FlxUIInputText;
	var scrollYInput:FlxUIInputText;
	var defaultZoomInput:FlxUIInputText;
	var usinAnimation_CB:FlxUICheckBox;
	var imageFile:String = '';

	function createTabMenu(id:String)
	{
		if (stageGrp == null)
		{
			stageGrp = new FlxTypedGroup<FlxSprite>();
			add(stageGrp);
		}

		if (blockControlOnTyping == null)
		{
			blockControlOnTyping = new FlxTypedGroup<FlxUIInputText>();
			add(blockControlOnTyping);
		}
		
		switch (id)
		{
			case 'Stage Assets':
				var nameInput:FlxUIInputText = new FlxUIInputText(20, 40, 80, "");
				scrollXInput = new FlxUIInputText(nameInput.x, nameInput.y + 40, 60, "1");
				scrollYInput = new FlxUIInputText(nameInput.x + scrollXInput.width + 10, nameInput.y + 40, 60, "1");
				var addImageBt:FlxButton = new FlxButton(nameInput.x, scrollXInput.y + 20, "Add Image", function()
				{
					imageFile = 'stage/' + nameInput.text;
					var wowlookatthis:FlxSprite = new FlxSprite();
					wowlookatthis.loadGraphic(imageFile + '.png');
					spriteNames.push(nameInput.text);
					wowlookatthis.scrollFactor.set(Std.parseFloat(scrollXInput.text), Std.parseFloat(scrollYInput.text));
					wowlookatthis.cameras = [camStage];
					stageGrp.add(wowlookatthis);
				});

				stageNumStepper = new FlxUINumericStepper(nameInput.x + 150, nameInput.y, 1, 0, 0, 30);
				var removeStageBt:FlxButton = new FlxButton(stageNumStepper.x, stageNumStepper.y + 20, "Remove Image", function()
				{
					spriteNames.remove(spriteNames[Std.int(stageNumStepper.value)]);
					stageGrp.members[Std.int(stageNumStepper.value)].kill();
					stageGrp.forEachDead(function(spr:FlxSprite)
					{
						stageGrp.remove(spr);
						stageGrp.length--;
						trace(stageGrp.length);
					});
				});

				defaultZoomInput = new FlxUIInputText(nameInput.x, addImageBt.y + 40, 60, "");
				for (i in [defaultZoomInput, scrollXInput, scrollYInput, nameInput])
				{
					blockControlOnTyping.add(i);
				}

				defaultZoomInput.cameras = [camHUD];
				nameInput.cameras = [camHUD];
				scrollXInput.cameras = [camHUD];
				scrollYInput.cameras = [camHUD];
				addImageBt.cameras = [camHUD];
				stageNumStepper.cameras = [camHUD];
				removeStageBt.cameras = [camHUD];
				
				var wow = new FlxUI(null, box);
				wow.name = 'Assets';

				wow.add(nameInput);
				wow.add(addImageBt);
				wow.add(stageNumStepper);
				wow.add(new FlxText(nameInput.x, nameInput.y - 20, 0, "Stage Image Name:"));
				wow.add(new FlxText(stageNumStepper.x, stageNumStepper.y - 20, 0, "Stage Number:"));
				wow.add(new FlxText(scrollXInput.x, scrollXInput.y - 20, 0, "Set Scroll Factor (X/Y):"));
				wow.add(new FlxText(defaultZoomInput.x, defaultZoomInput.y - 20, 0, "Default Cam Zoom:"));
				wow.add(scrollXInput);
				wow.add(scrollYInput);
				wow.add(removeStageBt);
				wow.add(defaultZoomInput);

				box.addGroup(wow);
			case 'Stage Settings':
				stageNumStepper2 = new FlxUINumericStepper(20, 40, 1, 0, 0, 30);

				scrollXInput = new FlxUIInputText(stageNumStepper2.x, stageNumStepper2.y + 40, 60, scrollXInput.text);
				scrollYInput = new FlxUIInputText(stageNumStepper2.x + scrollXInput.width + 10, stageNumStepper2.y + 40, 60, scrollXInput.text);

				var updateBt:FlxButton = new FlxButton(stageNumStepper2.x, scrollXInput.y + 20, "Update Image", updateImage);
				
				usinAnimation_CB = new FlxUICheckBox(stageNumStepper2.width + stageNumStepper2.x + 100, stageNumStepper2.y, null, null, 'Use Animation');
				usinAnimation_CB.checked = useAnimation;

				var animationNameInput:FlxUIInputText = new FlxUIInputText(usinAnimation_CB.x, usinAnimation_CB.y + 40, 100, "");
				var addAnimationBt:FlxButton = new FlxButton(usinAnimation_CB.x, animationNameInput.y + 40, "Add Animation", function()
				{
					if (animationNameInput.text != null)
						animations.push(animationNameInput.text);
					trace(animations);
				});

				var removeAnimBt:FlxButton = new FlxButton(addAnimationBt.x + addAnimationBt.width + 20, addAnimationBt.y, "Remove Animation", function()
				{
					if (animationNameInput.text != null)
						animations.remove(animationNameInput.text);
					stageGrp.members[Std.int(stageNumStepper2.value)].animation.remove(animationNameInput.text);
					trace(animations);
				});

				var playAnimBt:FlxButton = new FlxButton(addAnimationBt.x + addAnimationBt.width - 30, addAnimationBt.y + 30, "Play Animation", function()
				{
					if (animationNameInput != null)
						stageGrp.members[Std.int(stageNumStepper2.value)].animation.play(animationNameInput.text, true);
				});

				playAnimBt.cameras = [camHUD];
				removeAnimBt.cameras = [camHUD];
				addAnimationBt.cameras = [camHUD];
				animationNameInput.cameras = [camHUD];
				usinAnimation_CB.cameras = [camHUD];
				updateBt.cameras = [camHUD];
				scrollXInput.cameras = [camHUD];
				scrollYInput.cameras = [camHUD];
				stageNumStepper2.cameras = [camHUD];

				var wow = new FlxUI(null, box);
				wow.name = 'Settings';

				wow.add(new FlxText(stageNumStepper2.x, stageNumStepper2.y - 20, 0, "Stage Number:"));
				wow.add(new FlxText(scrollXInput.x, scrollXInput.y - 20, 0, "Set Scroll Factor (X/Y):"));
				wow.add(new FlxText(animationNameInput.x, animationNameInput.y - 20, 0, "Animation Name:"));
				wow.add(stageNumStepper2);
				wow.add(scrollXInput);
				wow.add(scrollYInput);
				wow.add(updateBt);
				wow.add(usinAnimation_CB);
				wow.add(animationNameInput);
				wow.add(addAnimationBt);
				wow.add(removeAnimBt);
				wow.add(playAnimBt);

				box.addGroup(wow);
		}
	}

	function updateImage()
	{
		if (stageGrp != null && stageNumStepper2 != null && stageGrp.members[Std.int(stageNumStepper2.value)] != null && stageGrp.length > 0)
		{
			trace(Std.int(stageNumStepper2.value));
			stageGrp.members[Std.int(stageNumStepper2.value)].scrollFactor.set(Std.parseFloat(scrollXInput.text), Std.parseFloat(scrollYInput.text));
			stageGrp.members[Std.int(stageNumStepper2.value)].frames = FlxAtlasFrames.fromSparrow(imageFile + '.png', imageFile + '.xml');
			if (useAnimation)
			{
				for (i in 0...animations.length)
				{
					stageGrp.members[Std.int(stageNumStepper2.value)].animation.addByPrefix(animations[i].toLowerCase(), animations[i], 24, false);
					stageGrp.members[Std.int(stageNumStepper2.value)].animation.play(animations[i].toLowerCase(), true);
					trace(animations[i].toLowerCase() + ' ' + animations[i]);
				}
			}
		}
	}
}