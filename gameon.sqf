/*
execute on all clients: 
[<blufor's trigger>, <opfor's trigger>, <array of vehicles to lock>] execVM "gameon.sqf";

if a player leaves their trigger they will be teleported to the trigger's center
player projectiles will be deleted instantly clientside
all vehicles in the array will be locked until game on
be sure each trigger is activated by its respective team
*/
if (isdedicated) then {} else {

bf = [] + list (_this select 0);
of = [] + list (_this select 1);
readyb = false;
readyo = false;

nobullets = player addeventhandler ["Fired", { deletevehicle (_this select 6);}];
{_x lock true} foreach (_this select 3);

(leader (bf select 0)) addaction ["GameOn: BLUFOR Ready", {
	readyb = true; publicvariable "readyb";
	(leader (bf select 0)) removeaction 0;
	(leader (bf select 0)) globalchat "[GameOn] BLUFOR is ready.";
}, "", 0, false, true];

(leader (of select 0)) addaction ["GameOn: OPFOR Ready", {
	readyo = true; publicvariable "readyo";
	(leader (of select 0)) removeaction 0;
	(leader (of select 0)) globalchat "[GameOn] OPFOR is ready.";
}, "", 0, false, true];

while {!(readyb && readyo)} do {
	if (count bf > count (list (_this select 0))) then {
		{ if (alive _x) then {_x setpos getpos (_this select 0)}} forEach (bf - list (_this select 0));
	};
	if (count of > count (list (_this select 1))) then {
		{if (alive _x) then {_x setpos getpos (_this select 1)}} forEach (of - list (_this select 1));
	};
	sleep 1;	
};

(leader (of select 0)) globalchat "[GameOn] OPFOR and BLUFOR are ready. Game on!";
player removeeventhandler ["Fired", nobullets];
{_x lock false} foreach (_this select 3);

deletevehicle (_this select 0);
deletevehicle (_this select 1);

};