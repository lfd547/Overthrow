private ["_data"];

//get all server data
"Loading persistent save" remoteExec['blackFaded',0,false];

_data = profileNameSpace getVariable ["Overthrow.save.001",""];
if(typename _data != "ARRAY") exitWith {
	[] remoteExec ['newGame',2];
	"No save found, starting new game" remoteExec ["hint",bigboss,true];
};

{
	_key = _x select 0;
	_val = _x select 1;
	_set = true;
	if(_key == "bases") then {
		{
			_pos = _x select 0;
			_name = _x select 1;
			_owner = _x select 2;
			
			_veh = createVehicle [OT_Item_Flag, _pos, [], 0, "CAN_COLLIDE"];
			_veh setVariable ["owner",_owner,true];
			_veh = createVehicle ["Land_ClutterCutter_large_F", _pos, [], 0, "CAN_COLLIDE"];
			
			_mrkid = format["%1-base",_pos];
			createMarker [_mrkid,_pos];
			_mrkid setMarkerShape "ICON";
			_mrkid setMarkerType "mil_Flag";
			_mrkid setMarkerColor "ColorWhite";
			_mrkid setMarkerAlpha 1;
			_mrkid setMarkerText _name;
		}foreach(_val);
	};
	if(_key == "vehicles") then {
		_set = false;
		{
			_type = _x select 0;
			
			
			
			if !(_type isKindOf "Man") then {
				_pos = _x select 1;
				_dir = _x select 2;
				_stock = _x select 3;
				_owner = _x select 4;
				_name = "";
				if(count _x > 5) then {
					_name = _x select 5;
				};
				
				_veh = _type createVehicle _pos;
				_veh setPos _pos;
				_veh setDir _dir;
				clearWeaponCargoGlobal _veh;
				clearMagazineCargoGlobal _veh;
				clearBackpackCargoGlobal _veh;
				clearItemCargoGlobal _veh;	
				_veh setVariable ["name",_name,true];
				
				_veh enableSimulationGlobal true;
				
				if(_type == OT_item_Map) then {
					_veh setObjectTextureGlobal [0,"dialogs\maptanoa.paa"];
				};
				
				if(_type in OT_staticMachineGuns) then {		
					_veh remoteExec["initStaticMGLocal",0,_veh];
				};
			
				_veh setVariable ["owner",_owner,true];
				{
					_cls = _x select 0;
					_num = _x select 1;
					call {
						if(_cls in OT_allWeapons) exitWith {
							_veh addWeaponCargoGlobal _x;
						};
						if(_cls in OT_allMagazines) exitWith {
							_veh addMagazineCargoGlobal _x;
						};
						if(_cls in OT_allBackpacks or _cls in OT_allStaticBackpacks) exitWith {
							_veh addBackpackCargoGlobal _x;
						};
						_veh addItemCargoGlobal _x;
					};	
				}foreach(_stock);
				
				if(count _x > 6) then {
					_code = (_x select 6);
					if(_code != "") then {
						[getpos _veh] execVM _code;
					};
				};
				
				if(_type == OT_policeStation) then {
					_town = _pos call nearestTown;
					_mrkid = format["%1-police",_town];
					createMarker [_mrkid,_pos];
					_mrkid setMarkerShape "ICON";
					_mrkid setMarkerType "o_installation";
					_mrkid setMarkerColor "ColorGUER";
					_mrkid setMarkerAlpha 1;
				};
			};
		}foreach(_val);
	};
	
	if(_set) then {
		server setvariable [_key,_val,true];
	};	
}foreach(_data);
sleep 2; //let the variables propagate
server setVariable ["StartupType","LOAD",true];
hint "Persistent Save Loaded";