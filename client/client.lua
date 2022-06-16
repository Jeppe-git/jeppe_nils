-- Jesper "jeppe" 2022

ESX = nil
StartedQuest = false
CarIsOut = false
PhoneNumber = exports["esx_phone3"]:GetMyPhoneNumber()
HasCar = false
Finished = false
InDialogue = false -- bara för buggfix

Citizen.CreateThread(
	function()
		while ESX == nil do
			TriggerEvent(
				"esx:getSharedObject",
				function(obj)
					ESX = obj
				end
			)
			Citizen.Wait(0)
		end
	end
)

local blip = AddBlipForCoord(-355.86, -1466.68, 30.87)
SetBlipSprite(blip, 133)
SetBlipScale(blip, 1.0)
SetBlipColour(blip, 2)

BeginTextCommandSetBlipName("STRING")
AddTextComponentSubstringPlayerName("Nils")
EndTextCommandSetBlipName(blip)

local NPC = {x = -355.86, y = -1466.68, z = 30.87, rotation = 84.27, NetworkSync = true}

Citizen.CreateThread(
	function()
		modelHash = GetHashKey(Config.PedModel)
		RequestModel(modelHash)
		while not HasModelLoaded(modelHash) do
			Wait(1)
		end
		createNPC()
	end
)

function createNPC()
	created_ped = CreatePed(0, modelHash, NPC.x, NPC.y, NPC.z - 1, NPC.rotation, NPC.NetworkSync)
	FreezeEntityPosition(created_ped, true)
	SetEntityInvincible(created_ped, true)
	SetBlockingOfNonTemporaryEvents(created_ped, true)
	TaskStartScenarioInPlace(created_ped, "WORLD_HUMAN_GUARD_STAND_CASINO", 0, true)
end

DrawMissionText = function(Data)
	ClearPrints()

	BeginTextCommandPrint("STRING")
	AddTextComponentSubstringPlayerName(type(Data) == "table" and Data.Text or Data)
	EndTextCommandPrint(type(Data) == "table" and (Data.Time or (99999 * 1000)) or (99999 * 1000), true)
end

FadeOut = function(duration)
	DoScreenFadeOut(duration)

	while not IsScreenFadedOut() do
		Wait(0)
	end
end

FadeIn = function(duration)
	DoScreenFadeIn(duration)

	while not IsScreenFadedIn() do
		Wait(0)
	end
end

Citizen.CreateThread(
	function()
		while true do
			local playerCoords = GetEntityCoords(PlayerPedId())
			local dst = GetDistanceBetweenCoords(-355.86, -1466.68, 30.87, playerCoords)
			Wait(0)

			if dst <= 1.5 then
				ESX.ShowHelpNotification("Tryck ~INPUT_CONTEXT~ för att prata med ~g~Nils")

				if IsControlJustReleased(0, 38) and StartedQuest == false and Finished == false and InDialogue == false then
					chooseQuest()
					PlaySoundFrontend(-1, "BACK", "HUD_AMMO_SHOP_SOUNDSET", 0)
				elseif IsControlJustReleased(0, 38) and StartedQuest == true and Finished == false then
					PlaySoundFrontend(-1, "BACK", "HUD_AMMO_SHOP_SOUNDSET", 0)
					ESX.ShowNotification("Vad vill du?!")
				elseif IsControlJustReleased(0, 38) and Finished then
					Finished = false
					InDialogue = true
					local value = reward
					local reward = math.ceil(math.random(250, 500))
					PlaySoundFrontend(-1, "BACK", "HUD_AMMO_SHOP_SOUNDSET", 0)
					ClearPrints()
					DrawMissionText("Tack som fan för hjälpen asså.")
					Wait(5000)
					PlaySoundFrontend(-1, "BACK", "HUD_AMMO_SHOP_SOUNDSET", 0)
					DrawMissionText("Här får du ~g~" .. reward .. "~w~ SEK som tack för din stora hjälp!")
					ESX.ShowNotification("Du tog emot " .. reward .. " SEK")
					TriggerServerEvent("jeppe_nils:Pay", value)
					Wait(5000)
					ClearPrints()
					StartedQuest = false
					PlaySoundFrontend(-1, "BASE_JUMP_PASSED", "HUD_AWARDS", false)
					ESX.Scaleform.ShowFreemodeMessage("~y~Uppdrag Avklarat", "~w~Du tjänade ~g~" .. reward .. "~w~ SEK", 7)
					PlaySoundFrontend(-1, "Hack_Success", "DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS", false)
					InDialogue = false
				end
			end
		end
	end
)

function chooseQuest()
	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open(
		"default",
		GetCurrentResourceName(),
		"nils",
		{
			title = "NILS",
			align = "center",
			elements = {
				{label = "BIL LEVERANS - QUEST", value = "cardelivery"},
				{label = "Jag är för lat för att lägga till nå mer", value = ""}
			}
		},
		function(data, menu)
			if data.current.value == "cardelivery" then
				ESX.UI.Menu.Open(
					"default",
					GetCurrentResourceName(),
					"cardelivery_menu",
					{
						title = "NILS - BIL LEVERANS",
						align = "center",
						elements = {
							{label = "STARTA", value = "start1"}
							--{label = 'Gå tillbaka', value = 'back'}
						}
					},
					function(data2, menu2)
						if data2.current.value == "start1" then
							PlaySoundFrontend(-1, "BACK", "HUD_AMMO_SHOP_SOUNDSET", 0)
							ESX.UI.Menu.CloseAll()
							menu2.close()
							menu.close()
							startQuest()
						end
					end,
					function(data2, menu2)
						menu2.close()
					end
				)
			end
		end,
		function(data, menu)
			menu.close()
		end
	)
end

function startQuest()
	local spawnChance = math.random(1, #Config["carlocations"])
	local spawnChanceCar = math.random(1, #Config["carmodels"])
	StartedQuest = true
	InDialogue = true
	FreezeEntityPosition(PlayerPedId(), true)
	FadeOut(2500)
	Wait(5000)
	FadeIn(2500)
	Wait(500)
	PlaySoundFrontend(-1, "BACK", "HUD_AMMO_SHOP_SOUNDSET", 0)
	DrawMissionText("Hej! Vill du tjäna en extra slant?")
	Wait(5000)
	PlaySoundFrontend(-1, "BACK", "HUD_AMMO_SHOP_SOUNDSET", 0)
	DrawMissionText("Okej, det kan nog gå och lösas. Jag kommer att skicka lite instruktioner till dig igenom min lur.")
	Wait(5000)
	PlaySoundFrontend(-1, "BACK", "HUD_AMMO_SHOP_SOUNDSET", 0)
	DrawMissionText("Följ mina instruktioner så kommer detta gå fint!")
	Wait(5000)
	PlaySoundFrontend(-1, "BACK", "HUD_AMMO_SHOP_SOUNDSET", 0)
	DrawMissionText("Juste, kom ihåg att du kan alltid använda ~r~/endnils~w~ för att avsluta uppdraget.")
	Wait(5000)
	DrawMissionText("Invänta ett samtal ifrån ~g~Nils~w~...")
	PlaySoundFrontend(-1, "BASE_JUMP_PASSED", "HUD_AWARDS", false)
	FreezeEntityPosition(PlayerPedId(), false)
	Wait(math.random(10000, 15000))
	ClearPrints()
	PlaySoundFrontend(-1, "Hack_Success", "DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS", false)
	TriggerServerEvent(
		"esx_phone:send",
		PhoneNumber,
		"Hej! Jag vill att du börjar genom att hämta min ".. Config["carmodels"][spawnChanceCar]["label"]..", jag kommer att skicka GPS koordinater till dig. Min GPS är ganska utdaterad så du kommer behöva triangulera den lite granna. Mvh Nils",
		true
	)
	InDialogue = false
	ESX.Game.SpawnVehicle(
		Config["carmodels"][spawnChanceCar]["carmodel"],
		Config["carlocations"][spawnChance]["coords"], Config["carlocations"][spawnChance]["heading"],
		function(vehicle)
			SetVehicleNumberPlateText(vehicle, "NILS")
			_G.vehicle = vehicle
			CarIsOut = true
			createZoneBlip(GetEntityCoords(vehicle, true))
			Wait(2000)
			FreezeEntityPosition(vehicle, true)
			SetEntityAsMissionEntity(vehicle, true, true)

			while CarIsOut do
				Wait(0)
				if IsPedInVehicle(PlayerPedId(), vehicle, false) then
					HasCar = true
					RemoveBlip(ZoneBlip)
					BringBackVehicle()
					break
				end
			end
		end
	)
end

function BringBackVehicle()
	InDialogue = true
	DrawMissionText("Mycket bra! Invänta ~g~Nils~w~ SMS...")
	Wait(math.random(20000, 50000))
	TriggerServerEvent(
		"esx_phone:send",
		PhoneNumber,
		"Har hört att du har hittat fordonet! Nu är det bara att köra tillbaka den till mig! Skickar min GPS-Punkt.",
		true
	)
	PlaySoundFrontend(-1, "Hack_Success", "DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS", false)
	SetNewWaypoint(-355.86, -1466.68)
	PlaySoundFrontend(-1, "BASE_JUMP_PASSED", "HUD_AWARDS", false)
	ClearPrints()
	FreezeEntityPosition(vehicle, false)
	InDialogue = false

	while HasCar do
		local vehCoords = GetEntityCoords(vehicle)
		local dstCheck1 = GetDistanceBetweenCoords(-359.42, -1459.6, 29.45, vehCoords, false)
		DrawMarker(
			36,
			-359.42,
			-1459.6,
			29.45,
			0.0,
			0.0,
			0.0,
			0.0,
			0,
			0.0,
			2.0,
			2.0,
			2.0,
			0,
			255,
			0,
			50,
			false,
			true,
			0,
			nil,
			nil,
			false
		)
		Wait(0)

		if dstCheck1 <= 2.5 and IsPedInVehicle(PlayerPedId(), vehicle, false) then
			ESX.ShowHelpNotification("Tryck ~INPUT_CONTEXT~ för att ge tillbaka bilen till ~g~Nils", true, true)

			if IsControlJustReleased(0, 38) and IsPedInVehicle(PlayerPedId(), vehicle, false) then
				TaskLeaveVehicle(PlayerPedId(), vehicle, 0)
				Wait(2000)
				HasCar = false
				Finished = true
				ESX.Game.DeleteVehicle(vehicle)
				PlaySoundFrontend(-1, "Hack_Success", "DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS", false)
				DrawMissionText("Mycket bra! Snacka med ~g~Nils~w~ för att få din lön")
			end
		end
	end
end

RegisterCommand(
	"endnils",
	function()
	endQuest()
	end
)

function createZoneBlip(coords)
	local zoneCoords = vector3(coords)
	_G.ZoneBlip = AddBlipForRadius(zoneCoords, 1500.0)
	SetBlipSprite(ZoneBlip, Config.BlipSprite)
	SetBlipColour(ZoneBlip, Config.BlipColor)
	--SetBlipAlpha(ZoneBlip, 161)
end

function endQuest()
	if StartedQuest == true and InDialogue == false then
		StartedQuest = false
		ESX.Game.DeleteVehicle(vehicle)
		HasCar = false
		Finished = false
		CarIsOut = false
		ClearGpsPlayerWaypoint()
		ClearPrints()
		RemoveBlip(ZoneBlip)
		ESX.ShowNotification("Du avslutade Nils uppdrag")
	elseif StartedQuest == true and InDialogue == true then
		ESX.ShowNotification("Du kan inte avsluta just nu!")
	else
		ESX.ShowNotification("Du har inte ens startat något uppdrag!")
	end
end