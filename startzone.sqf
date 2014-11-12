while {!isNull startB} do
{
	sleep 1;
	if ((count units group player) > count (list startB)) then
	{
		total = units group player;
		inside = list startB;
		missing = total - inside;
		{_x setpos position startB} forEach missing;		
	};	
};