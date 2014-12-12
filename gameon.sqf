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

// Setup variables
readyb = false;
readyo = false;

_bfLeader = objNull;
_ofLeader = objNull;

_bfRating = -1; // Privates are rated 0
_ofRating = -1;

_bfTrig = _this select 0;
_ofTrig = _this select 1;

_bfPlayers = [] + list _bfTrig;
_ofPlayers = [] + list _ofTrig;

_vehicles = _this select 4;


// Find side leaders
if (isPlayer (_this select 2)) then  { _bfLeader = _this select 2;};
if (isPlayer (_this select 3)) then  { _ofLeader = _this select 3;};
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

// Give leaders GameOn addAction
bfGameOnAction = if (player == _bfLeader) then {
	player addaction ["GameOn: BLUFOR Ready", {
		readyb = true;
		publicvariable "readyb";
		player removeaction bfGameOnAction;
		["[GameOn] BLUFOR is ready.", "systemchat", true] call BIS_fnc_MP;
	}, player, 0, false, true];
};

ofGameOnAction = if (player == _ofLeader) then {
	player addaction ["GameOn: OPFOR Ready", {
		readyo = true;
		publicvariable "readyo";
		player removeaction ofGameOnAction;
		["[GameOn] OPFOR is ready.", "systemchat", true] call BIS_fnc_MP;
	}, player, 0, false, true];
};

// Disable damage and bullets
player allowDamage false;
_noBullets = player addeventhandler ["Fired", { deletevehicle (_this select 6);}]; // deletes all fired munitions including thrown objects

// Lock vehicles
if (count (_vehicles) != 0) then 
{
	{_x lock true} foreach _vehicles;
};

// Teleport players back to spawn
while {!(readyb && readyo)} do {
	if (count _bfPlayers > count (list _bfTrig)) then 
	{
		{ 
			if (alive _x) then 
			{
				_x setpos getpos _bfTrig;
			}
		} forEach (_bfPlayers - (list _bfTrig));
	};
	if (count _ofPlayers > count (list _ofTrig)) then 
	{
		{
			if (alive _x) then 
			{
				_x setpos getpos _ofTrig;
			}
		} forEach (_ofPlayers - (list _ofTrig));
	};
	
	// anything you want done every second until game on goes here
	
	sleep 1.0;
};

// Game On

// Chat messages
systemchat "[GameOn] BLUFOR and OPFOR are ready.";
sleep 2.0;
{systemchat _x; sleep 0.5;} foreach [ "3", "2", "1", "Let's jam."];

// Enable damage, remove bullet event handler
player allowDamage true;
player removeeventhandler ["Fired", _noBullets];

// Unlock vehicles
if (count _vehicles != 0) then 
{
	{_x lock false;} forEach _vehicles;
};

// Delete spawn triggers
deletevehicle (_bfTrig);
deletevehicle (_ofTrig);
