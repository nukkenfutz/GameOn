/*
execute through init: 
[<blufor's trigger>, <opfor's trigger>, <blufor leader>, <opfor leader>, <array of vehicles to lock>] execVM "gameon.sqf";
be sure each trigger is activated by its respective team
all players must be within their team's trigger on execution
gameon action added to the leader units given, those slots must be occupied
to leave the triggers, remove the deletevehicles commented at the end

if a player leaves their trigger they will be teleported to the trigger's center
player projectiles will be deleted instantly clientside
all vehicles in the array will be locked until game on
*/

readyb = false;
readyo = false;

_bfLeader = _this select 2;
_ofLeader = _this select 3;

_bfRating = 0;
_ofRating = 0;

_bfTrig = _this select 0;
_ofTrig = _this select 1;

_bfPlayers = [] + list _bfTrig;
_ofPlayers = [] + list _ofTrig;

_vehicles = _this select 4;


{
	if (alive _x && isPlayer _x) then
	{
		if (side _x == WEST) then
		{
			if (isNull _bfLeader) then
			{
				_rating = rating _x;
				if (_rating> _bfRating) then
				{
					_bfRating = _rating;
					_bfLeader = _x;
				};
			};
		}
		else
		{
			if (isNull _ofLeader) then
			{
				_rating = rating _x;
				if (_rating> _ofRating) then
				{
					_ofRating = _rating;
					_ofLeader = _x;
				};
			};
		};
	};
} forEach allUnits;

if (player == _bfLeader) then {
	player addaction ["GameOn: BLUFOR Ready", {
		readyb = true;
		publicvariable "readyb";
		player removeaction 0;
		["[GameOn] BLUFOR is ready.", "systemchat", true] call BIS_fnc_MP;
	}, player, 0, false, true];
};

if (player == _ofLeader) then {
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
	if (count _bfPlayers > count (list _bfTrig)) then 
	{
		{ 
			if (alive _x) then 
			{
				_x setpos getpos _bfTrig;
			}
		} forEach (bf - (list _bfTrig));
	};
	if (count _ofPlayers > count (list _ofTrig)) then 
	{
		{
			if (alive _x) then 
			{
				_x setpos getpos _ofTrig;
			}
		} forEach (of - (list _ofTrig));
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
