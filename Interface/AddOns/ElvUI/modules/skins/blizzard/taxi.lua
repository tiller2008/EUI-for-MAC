local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.taxi then return end

	local TaxiFrame = _G.TaxiFrame
	S:HandleFrame(TaxiFrame, true, nil, 11, -12, -32, 76)
	_G.TaxiPortrait:Kill() -- Blizz didnt name this TaxiFramePortrait

	S:HandlePointXY(_G.TaxiMap, -11, -71)
	S:HandlePointXY(_G.TaxiRouteMap, -11, -71)

	_G.TaxiMerchant:SetTextColor(1, 1, 1)

	S:HandleCloseButton(_G.TaxiCloseButton, TaxiFrame.backdrop)
end

S:AddCallback('Skin_Taxi', LoadSkin)