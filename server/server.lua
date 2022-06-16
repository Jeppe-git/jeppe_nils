-- Jesper "jeppe" 2022

ESX = nil

TriggerEvent('esx:getSharedObject', function(obj)
    ESX = obj
  end)

RegisterServerEvent("jeppe_nils:Pay")
AddEventHandler("jeppe_nils:Pay", function(value)
    local Player = ESX.GetPlayerFromId(source)

    Player.addMoney(value)
end)

