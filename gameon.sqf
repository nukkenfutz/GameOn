/*
execute though init: 
[<blufor's trigger>, <blufor leader>, <opfor's trigger>, <opfor leader>, <array of vehicles to lock>] execVM "gameon.sqf";
be sure each trigger is activated by its respective team
all players must be within their team's trigger on execution
gameon action added to the leader units given, those slots must be occupied
to leave the triggers, remove the deletevehicles commented at the end

if a player leaves their trigger they will be teleported to the trigger's center
player projectiles will be deleted instantly clientside
all vehicles in the array will be locked until game on
*/

bf = [] + list (_this select 0);
of = [] + list (_this select 2);
readyb = false;
readyo = false;

if (player == (_this select 1)) then {
	player addaction ["GameOn: BLUFOR Ready", {
		readyb = true;
		publicvariable "readyb";
		player removeaction 0;
		["[GameOn] BLUFOR is ready.", "systemchat", true] call BIS_fnc_MP;
	}, player, 0, false, true];
};

if (player == (_this select 3)) then {
	player addaction ["GameOn: OPFOR Ready", {
		readyo = true;
		publicvariable "readyo";
		player removeaction 0;
		["[GameOn] OPFOR is ready.", "systemchat", true] call BIS_fnc_MP;
	}, player, 0, false, true];
};

player allowDamage false;
nobullets = player addeventhandler ["Fired", { deletevehicle (_this select 6);}];
if (count (_this select 4) != 0) then {{_x lock true} foreach (_this select 4);};

while {!(readyb && readyo)} do {
	if (count bf > count (list (_this select 0))) then {
		{ if (alive _x) then {_x setpos getpos (_this select 0)}} forEach (bf - list (_this select 0));
	};
	if (count of > count (list (_this select 2))) then {
		{if (alive _x) then {_x setpos getpos (_this select 2)}} forEach (of - list (_this select 2));
	};
	// anything you want done every second until game on goes here
	sleep 1;
};

{systemchat _x; sleep 1;} foreach ["[GameOn] BLUFOR and OPFOR are ready.", "3", "2", "1", "Game on."];
player allowDamage true;
player removeeventhandler ["Fired", nobullets];
if (count (_this select 4) != 0) then {{_x lock false} foreach (_this select 4);};
deletevehicle (_this select 0); //remove these if you dont want the passed triggers deleted
deletevehicle (_this select 2); //
