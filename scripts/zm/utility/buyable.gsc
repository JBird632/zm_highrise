#using scripts\zm\_zm_score;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_audio;

#namespace Buyable;

class Buyable
{
	var _trigger;
	var _cost;
	var _onPurchaseCallback;
	var _numPurchases;
	var _maxPurchases;
	var _hintstring;

	function Initialize(trigger, cost)
	{
		Assert(IsEntity(trigger), "<trigger> should be a trigger entity");

		_numPurchases = 0;
		self SetCost(cost);
		self SetupTrigger(trigger);

		if (isdefined(_hintstring))
			self SetTriggerHintstring(_hintstring);

		self thread WatchTrigger();
	}

	function SetCost(cost)
	{
		Assert(IsInt(cost), "<cost> should be an integer value");
		Assert(cost >= 0, "<cost> should be a greater than or equal to zero");

		_cost = cost;
	}

	function SetupTrigger(trigger)
	{
		_trigger = trigger;
		_trigger SetCursorHint("HINT_NOICON");
		_trigger UseTriggerRequireLookAt();

		if (isdefined(_hintstring))
			_trigger SetHintString(_hintstring, _cost);
	}

	function SetTriggerHintstring(hintstring)
	{
		Assert(IsString(hintstring), "<hintstring> should be a string value");
		_hintstring = hintstring;

		if (isdefined(_trigger))
			_trigger SetHintString(_hintstring, _cost);
	}

	function SetMaxPurchases(maxPurchases)
	{
		Assert(IsInt(maxPurchases), "<maxPurchases> should be an integer value");
		Assert(maxPurchases > 0 || maxPurchases == -1, "<maxPurchases> should be a greater than zero (-1 for no maxPurchases)");

		_maxPurchases = maxPurchases;
	}

	function WatchTrigger()
	{
		self endon("destroy");

		while(true)
		{
			_trigger waittill("trigger", player);

			if (!IsPlayer(player))
				continue;

			if (self CanPlayerPurchase(player))
			{
				_numPurchases++;
				player zm_score::minus_to_player_score(_cost);
				zm_utility::play_sound_at_pos("purchase", _trigger.origin);

				if (isdefined(_onPurchaseCallback))
					self thread [[_onPurchaseCallback]](player);

				if (_numPurchases >= _maxPurchases && _maxPurchases > 0)
				{
					_trigger Delete();
					break;
				}
			}
			else
			{
				zm_utility::play_sound_at_pos("no_purchase", _trigger.origin);
				player zm_audio::create_and_play_dialog("general", "outofmoney");
			}
		}
	}

	function CanPlayerPurchase(player)
	{
		return player zm_score::can_player_purchase(_cost);
	}
}
