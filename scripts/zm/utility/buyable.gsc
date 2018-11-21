#using scripts\zm\_zm_score;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_audio;

#namespace Buyable;

class Buyable
{
	var _trigger;
	var _cost;
	var _onPurchaseCallback;
	var _canPurchase;
	var _numPurchases;
	var _maxPurchases;
	var _hintstring;

	function InitializeBuyable(trigger, cost)
	{
		_canPurchase = true;
		_numPurchases = 0;
		SetCost(cost);
		SetTrigger(trigger);

		if (isdefined(_hintstring))
			SetTriggerHintstring(_hintstring, true);

		thread WatchTrigger();
	}

	function SetCost(cost)
	{
		Assert(IsInt(cost), "<cost> should be an integer value");
		Assert(cost >= 0, "<cost> should be a greater than or equal to zero");

		_cost = cost;
	}

	function SetTrigger(trigger)
	{
		Assert(IsEntity(trigger), "<trigger> should be a trigger entity");

		_trigger = trigger;
		_trigger SetCursorHint("HINT_NOICON");
		_trigger UseTriggerRequireLookAt();

		if (isdefined(_hintstring))
			_trigger SetHintString(_hintstring, _cost);
	}

	function SetTriggerHintstring(hintstring, includeCost)
	{
		Assert(IsString(hintstring), "<hintstring> should be a string value");

		if (!isdefined(_hintstring))
			_hintstring = hintstring;

		if (isdefined(_trigger) && includeCost)
			_trigger SetHintString(hintstring, _cost);
		else if (isdefined(_trigger))
			_trigger SetHintString(hintstring);
	}

	function SetCanPurchase(toggle)
	{
		_canPurchase = toggle;
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

			if (CanPlayerPurchase(player))
			{
				_numPurchases++;
				player zm_score::minus_to_player_score(_cost);
				zm_utility::play_sound_at_pos("purchase", _trigger.origin);

				if (isdefined(_onPurchaseCallback))
					thread [[_onPurchaseCallback]](player);

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
		return player zm_score::can_player_purchase(_cost) && _canPurchase;
	}
}
