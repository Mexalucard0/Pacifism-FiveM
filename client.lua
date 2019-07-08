-- Config
local disableOnAttack = true
--

local isPacifist = false
local plyPed


RegisterCommand("pacifist", function(src,args)
  setPacifism(not isPacifist)
end)


Citizen.CreateThread(function()
  TriggerEvent('chat:addSuggeston', '/pacifist', 'Turns off melee and weapon firing.', {})
end)


function enablePacifism()
  Citizen.CreateThread(function()
    plyPed = PlayerPedId()
    while isPacifist do
      DisablePlayerFiring(plyPed, true)
      DisableControlAction(1, 140, true)
      DisableControlAction(1, 141, true)
      DisableControlAction(1, 142, true)
      Citizen.Wait(0)
    end
  end)

  Citizen.CreateThread(function()
    while isPacifist do
      plyPed = PlayerPedId()
      Citizen.Wait(1000)
    end
  end)
end


if disableOnAttack then
  AddEventHandler('gameEventTriggered', function (name, args)
    --print('game event ' .. name .. ' (' .. json.encode(args) .. ')')
    if name == 'CEventNetworkEntityDamage' then
      local victim, attacker, weaponHash, isMelee = table.unpack(args)
      --print(victim, attacker, weaponHash, isMelee)
      local plyPed = PlayerPedId()
      if victim == plyPed and attacker ~= plyPed then
        if isPacifist then setPacifism(false, "Attacked! Pacifism disabled.") end
        TriggerEvent("pacifism:attacked")
      end
    end
  end)
end


function triggerMessage(msg)
  TriggerEvent('chat:addMessage', {
    color = {255, 0, 0},
    multiline = true,
    args = {"Me", msg}
  })
end


function setPacifism(bool, msg)
  if bool == isPacifist then return end
  if bool == true then isPacifist = true
  elseif bool == false then isPacifist = false
  else
    print("Pacifist must be set to true or false")
    return
  end
  triggerMessage(msg or "Pacifism is " .. tostring(isPacifist))
  TriggerEvent("pacifism:set", bool)
  if isPacifist then
    enablePacifism()
  end
end

function isEnabled()
	return isPacifist
end
exports('isEnabled', isEnabled)
exports('set', setPacifism)
