/*
execute though init: 
[<blufor's trigger>, <blufor leader>, <opfor's trigger>, <opfor leader>, <array of vehicles to lock>] execVM "gameon.sqf";
be sure each trigger is activated by its respective team
all players must be within their team's trigger on execution
gameon action added to the leader units given, those slots must be occupied

if a player leaves their trigger they will be teleported to the trigger's center
player projectiles will be deleted instantly clientside
all vehicles in the array will be locked until game on
*/

bf = [] + list (_this select 0);
of = [] + list (_this select 2);
readyb = false;
readyo = false;

if (isserver) then {

	[[(_this select 1),{
		(_this select 0) addaction ["GameOn: BLUFOR Ready", {
			readyb = true;
			publicvariable "readyb";
			(_this select 3) removeaction 0;
			["[GameOn] BLUFOR is ready.", systemchat, true] call BIS_fnc_MP;
		}, (_this select 0), 0, false, true];
	}], "BIS_fnc_spawn", (_this select 1)] call BIS_fnc_MP;

	[[(_this select 3),{
		(_this select 0) addaction ["GameOn: OPFOR Ready", {
			readyo = true;
			publicvariable "readyo";
			(_this select 3) removeaction 0;
			["[GameOn] OPFOR is ready.", systemchat, true] call BIS_fnc_MP;
		}, (_this select 0), 0, false, true];
	}], "BIS_fnc_spawn", (_this select 3)] call BIS_fnc_MP;
	
};

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

systemchat "[GameOn] BLUFOR and OPFOR are ready. Game on.";
player removeeventhandler ["Fired", nobullets];
if (count (_this select 4) != 0) then {{_x lock false} foreach (_this select 4);};
deletevehicle (_this select 0);
deletevehicle (_this select 2);
