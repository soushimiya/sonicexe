package art;
import sys.FileSystem;
import sys.io.File;
import haxe.Json;

using StringTools;

// convert psych v..0.4.2 chart events into fps plus format and do some cool stuff idkkk
class PsychEventConverter
{
    static var fpsPlusEvents:Array<Array<Dynamic>> = []; // uh
    static var curSection:Int = 0;
    
    public static function main()
    {
        trace("Enter events.json Path!");
		var dataPath = Sys.stdin().readLine().trim();

		if (!FileSystem.exists(dataPath))
		{
			trace('No Event File Exist on ($dataPath) !!');
			return;
		}
        var impostorJson:PsychEventsLegacy = Json.parse(File.getContent(dataPath)).song;
        
        var ignoreEvents:Array<String> = [];
        curSection = 0;
        for (section in impostorJson.notes)
        {
            for (event in section.sectionNotes)
            {
                if (event[1] != -1) // chart file w/ event thing support ig
                    continue;
                // then doing converting stuff lol
                var eventTime = event[0];
                var eventName = event[2];
                var eventValue1 = event[3];
                var eventValue2 = event[4];

                if (ignoreEvents.contains(eventName))
                    continue;

                switch(eventName)
                {
                    case "Add Camera Zoom":
                        pushEvent("camBop", [], eventTime);
                    case "Change Character":
                        var char:Int = Std.parseInt(eventValue1);
                        if (Math.isNaN(char))
                        {
                            switch (eventValue2.toLowerCase())
				            {
					            case 'mom' | 'opponent2':
						            char = 3;
					            case 'gf' | 'girlfriend':
					            	char = 2;
					            case 'dad' | 'opponent':
					    	        char = 1;
                                default:
                                    char = 0;
                            }
                        }
                        
                        var actualChar = ["bf", "dad", "gf"][char];
                        pushEvent("changeCharacter", [actualChar, eventValue2], eventTime);
                    case "Play Animation":
                        var char = eventValue2.toLowerCase();
                        if (eventValue2 == "0") char = "dad";
                        if (eventValue2 == "1" || eventValue2 == "boyfriend") char = "bf";
                        if (eventValue2 == "2" || eventValue2 == "girlfriend") char = "gf";

                        pushEvent("playAnim", [char, eventValue1, true], eventTime);

                    // evil scary events
                    default:
                        // Don't you think it's ridiculous to give multiple notices????????
                        trace("Found undefined event " + eventName + "! ignoring....");
                        ignoreEvents.push(eventName);
                }
            }
            curSection += 1;
        }

        File.saveContent(dataPath.split(".json")[0] + "-converted.json", Json.stringify({events: {events: fpsPlusEvents}}, "\t"));
    }

    static function pushEvent(name:String, args:Array<Dynamic>, time:Float, id:Int = 0)
    {
        if (args.join(";").length < -1)
            args = [];
        
        if (args.length > 0)
            name += ";";

        fpsPlusEvents.push(
            [
                curSection,
                time,
                id,
                name + args.join(";")
            ]
        );
    }
}

// Only the bare minimum
typedef PsychEventsLegacy = {
    var notes:Array<PsychSection>;
}

typedef PsychSection = {
    var sectionNotes:Array<Array<Dynamic>>;
}