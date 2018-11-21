#using scripts\zm\utility\buyable;
#using scripts\shared\flag_shared;

#namespace Trap;

class Trap : Buyable
{
	var _name;
	var _duration;
	var _cooldown;
	var _requiresPower;
	var _activateTrapCallback;
	var _deactivateTrapCallback;
	var _reactivateTrapCallback;
	var _activeHintstring;
	var _cooldownHintstring;
	var _powerOnCallback;

	function InitializeTrap(name, trigger, cost, duration, cooldown, requiresPower)
	{
		SetName(name);
		SetDuration(duration);
		SetCoolDown(cooldown);
		_hintstring = "Hold ^3[{+activate}]^7 to activate " + _name + " [Cost: &&1]";
		_onPurchaseCallback = &OnPurchase;
		InitializeBuyable(trigger, cost);
		SetRequiresPower(requiresPower);
	}

	function SetName(name)
	{
		Assert(IsString(name), "<name> should be a string value");
		_name = name;
	}

	function SetDuration(duration)
	{
		Assert(IsInt(duration), "<duration> should be an integer value");
		Assert(duration >= 0, "<duration> should be a greater than or equal to zero");

		_duration = duration;
	}

	function SetCoolDown(cooldown)
	{
		Assert(IsInt(cooldown), "<cooldown> should be an integer value");
		Assert(cooldown >= 0, "<cooldown> should be a greater than or equal to zero");

		_cooldown = cooldown;
	}

	function SetRequiresPower(requiresPower)
	{
		_requiresPower = requiresPower;

		if (requiresPower)
		{
			SetCanPurchase(false);
			SetTriggerHintString(&"ZOMBIE_NEED_POWER", false);
			thread WaitForPower();
		}
	}

	function WaitForPower()
	{
		level flag::wait_till("power_on");
		SetCanPurchase(true);
		SetTriggerHintString(_hintstring, true);

		if (isdefined(_powerOnCallback))
			thread [[_powerOnCallback]]();
	}

	function OnPurchase(player)
	{
		SetCanPurchase(false);
		SetTriggerHintString((isdefined(_activeHintstring) ? _activeHintstring : &"ZOMBIE_TRAP_ACTIVE"), false);

		if (isdefined(_activateTrapCallback))
			thread [[_activateTrapCallback]](player, _duration);

		wait(_duration);
		SetTriggerHintString((isdefined(_cooldownHintstring) ? _cooldownHintstring : &"ZOMBIE_TRAP_COOLDOWN"), false);

		if (isdefined(_deactivateTrapCallback))
			thread [[_deactivateTrapCallback]](player, _cooldown);

		wait(_cooldown);
		SetCanPurchase(true);
		SetTriggerHintString(_hintstring, true);

		if (isdefined(_reactivateTrapCallback))
			thread [[_reactivateTrapCallback]](player);
	}
}
