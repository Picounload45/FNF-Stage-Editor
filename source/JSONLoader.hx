package;

import PlayState.StageJSON;
import haxe.Json;
import openfl.net.FileReference;
import sys.FileSystem;
import sys.io.File;

using StringTools;

/**
 * A Simple Tools For Saving/Loding Json
 *
 * `WARNING: THIS ONLY FOR STAGEJSON!!`
 */
class JSONMenu
{
    /**
    * loades a StageJson File.
    */
    public static function load(path:String):StageJSON
    {
        var json:String = path;
        if (!path.contains('.json')) json = path + '.json';
        trace(json);
        var why = File.getContent(json);
        trace(why);
        var jsonFile:StageJSON = Json.parse(why);
        trace(jsonFile);
        return jsonFile;
    }

    public static var jsonRe:FileReference;

    /**
    * Saves A StageJson File
    **/
    public static function save()
    {
        var jsonFile = PlayState.GOD;
        var newJSON = Json.stringify(jsonFile, "\t");
        trace(newJSON.trim());

        if (newJSON != null && newJSON.length > 0)
        {
            jsonRe = new FileReference();
            jsonRe.save(newJSON.trim(), "stage1.json");
        }
    }
}