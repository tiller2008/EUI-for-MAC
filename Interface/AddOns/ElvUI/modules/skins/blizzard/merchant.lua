local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local unpack = unpack
--WoW API / Variables
local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
local hooksecurefunc = hooksecurefunc

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.merchant then return end

	local MerchantFrame = _G.MerchantFrame
	S:HandleFrame(MerchantFrame, true, nil, -5, 0, 1, -1)

	_G.MerchantFrameCloseButton:Point('TOPRIGHT', 2, 2)

	-- skin icons / merchant slots
	for i = 1, _G.BUYBACK_ITEMS_PER_PAGE do
		local item = _G['MerchantItem'..i]
		local button = _G['MerchantItem'..i..'ItemButton']
		local icon = _G['MerchantItem'..i..'ItemButtonIconTexture']
		local money = _G['MerchantItem'..i..'MoneyFrame']
		local nameFrame = _G['MerchantItem'..i..'NameFrame']
		local name = _G['MerchantItem'..i..'Name']
		local slot = _G['MerchantItem'..i..'SlotTexture']

		item:StripTextures(true)
		item:CreateBackdrop('Default')
		item.backdrop:Point('TOPLEFT', -1, 3)
		item.backdrop:Point('BOTTOMRIGHT', 2, -3)

		button:StripTextures()
		button:StyleButton()
		button:SetTemplate('Default', true)
		button:Size(40)
		button:Point('TOPLEFT', item, 'TOPLEFT', 4, -2)

		icon:SetTexCoord(unpack(E.TexCoords))
		icon:SetInside()

		nameFrame:Point('LEFT', slot, 'RIGHT', -6, -17)

		name:Point('LEFT', slot, 'RIGHT', -4, 5)

		money:ClearAllPoints()
		money:Point('BOTTOMLEFT', button, 'BOTTOMRIGHT', 3, 0)

		for j = 1, 2 do
			local currencyItem = _G['MerchantItem'..i..'AltCurrencyFrameItem'..j]
			local currencyIcon = _G['MerchantItem'..i..'AltCurrencyFrameItem'..j..'Texture']

			currencyIcon.backdrop = CreateFrame('Frame', nil, currencyItem)
			currencyIcon.backdrop:SetTemplate('Default')
			currencyIcon.backdrop:SetFrameLevel(currencyItem:GetFrameLevel())
			currencyIcon.backdrop:SetOutside(currencyIcon)

			currencyIcon:SetTexCoord(unpack(E.TexCoords))
			currencyIcon:SetParent(currencyIcon.backdrop)
		end
	end

	_G.MerchantNameText:SetTextColor(1, 1, 1)

	_G.MerchantPageText:SetTextColor(1, 1, 1)
	_G.MerchantPageText:Point('BOTTOM', -2, 10)

	S:HandleNextPrevButton(_G.MerchantNextPageButton, nil, nil, nil, true)
	_G.MerchantNextPageButton:Point('BOTTOMRIGHT', _G.MerchantFrame, 'BOTTOMRIGHT', -11, 10)
	_G.MerchantNextPageButton:Size(24)

	S:HandleNextPrevButton(_G.MerchantPrevPageButton, nil, nil, nil, true)
	_G.MerchantPrevPageButton:Point('TOPLEFT', _G.MerchantNextPageButton, 'TOPLEFT', -30, 0)
	_G.MerchantPrevPageButton:Size(24)

	S:HandleButton(_G.MerchantRepairItemButton)
	_G.MerchantRepairItemButton:StyleButton(false)
	_G.MerchantRepairItemButton:GetRegions():SetTexCoord(0.04, 0.24, 0.07, 0.5)
	_G.MerchantRepairItemButton:GetRegions():SetInside()

	S:HandleButton(_G.MerchantRepairAllButton)
	_G.MerchantRepairAllIcon:StyleButton(false)
	_G.MerchantRepairAllIcon:SetTexCoord(0.34, 0.1, 0.34, 0.535, 0.535, 0.1, 0.535, 0.535)
	_G.MerchantRepairAllIcon:SetInside()

	_G.MerchantRepairAllButton:ClearAllPoints()
	_G.MerchantRepairAllButton:Point('BOTTOMLEFT', _G.MerchantFrame, 'BOTTOMLEFT', 124, 57)

	_G.MerchantMoneyBg:StripTextures()
	_G.MerchantMoneyInset:StripTextures()

	_G.MerchantMoneyFrame:ClearAllPoints()
	_G.MerchantMoneyFrame:Point('BOTTOMLEFT', _G.MerchantFrame, 'BOTTOMLEFT', 7, 10)

	S:HandleFrame(_G.MerchantBuyBackItem, true, nil, -1, 3, 2, -2)
	_G.MerchantBuyBackItem:Height(46)
	S:HandlePointXY(_G.MerchantBuyBackItem, 0, -16)

	_G.MerchantBuyBackItemItemButton:StripTextures()
	_G.MerchantBuyBackItemItemButton:StyleButton()
	_G.MerchantBuyBackItemItemButton:SetTemplate('Default', true)
	_G.MerchantBuyBackItemItemButton:Size(40)
	_G.MerchantBuyBackItemItemButton:Point('TOPLEFT', 4, -2)

	_G.MerchantBuyBackItemItemButtonIconTexture:SetTexCoord(unpack(E.TexCoords))
	_G.MerchantBuyBackItemItemButtonIconTexture:SetInside()

	_G.MerchantBuyBackItemNameFrame:Point('LEFT', _G.MerchantBuyBackItemSlotTexture, 'RIGHT', -6, -17)

	_G.MerchantBuyBackItemName:Point('LEFT', _G.MerchantBuyBackItemSlotTexture, 'RIGHT', -4, 5)

	_G.MerchantBuyBackItemMoneyFrame:ClearAllPoints()
	_G.MerchantBuyBackItemMoneyFrame:Point('BOTTOMLEFT', _G.MerchantBuyBackItemItemButton, 'BOTTOMRIGHT', 3, 0)

	local function merchantItemPoint()
		S:HandlePointXY(_G.MerchantItem1, 6, -40)

		-- evens
		for i = 3, _G.BUYBACK_ITEMS_PER_PAGE, 2 do
			S:HandlePointXY(_G['MerchantItem'..i], 0, -16)
		end
		-- odds
		for i = 2, _G.BUYBACK_ITEMS_PER_PAGE, 2 do
			S:HandlePointXY(_G['MerchantItem'..i], 12, 0)
		end
	end

	-- skin tabs
	for i = 1, 2 do
		S:HandleTab(_G['MerchantFrameTab'..i])
	end

	hooksecurefunc('MerchantFrame_UpdateMerchantInfo', function()
		local numMerchantItems = GetMerchantNumItems()
		local index = (MerchantFrame.page - 1) * MERCHANT_ITEMS_PER_PAGE
		local button, name, quality

		for i = 1, _G.BUYBACK_ITEMS_PER_PAGE do
			index = index + 1

			if index <= numMerchantItems then
				button = _G['MerchantItem'..i..'ItemButton']
				name = _G['MerchantItem'..i..'Name']

				if button.link then
					quality = select(3, GetItemInfo(button.link))

					if quality and quality > 1 then
						local r, g, b = GetItemQualityColor(quality)
						button:SetBackdropBorderColor(r, g, b)
						name:SetTextColor(r, g, b)
					else
						button:SetBackdropBorderColor(unpack(E.media.bordercolor))
						name:SetTextColor(1, 1, 1)
					end
				else
					button:SetBackdropBorderColor(unpack(E.media.bordercolor))
					name:SetTextColor(1, 1, 1)
				end
			end

			local itemName = GetBuybackItemInfo(GetNumBuybackItems())
			if itemName then
				quality = select(3, GetItemInfo(itemName))

				if quality and quality > 1 then
					local r, g, b = GetItemQualityColor(quality)
					MerchantBuyBackItemItemButton:SetBackdropBorderColor(r, g, b)
					MerchantBuyBackItemName:SetTextColor(r, g, b)
				else
					MerchantBuyBackItemItemButton:SetBackdropBorderColor(unpack(E.media.bordercolor))
					MerchantBuyBackItemName:SetTextColor(1, 1, 1)
				end
			else
				MerchantBuyBackItemItemButton:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end
		end

		_G.MerchantRepairText:Point('BOTTOMLEFT', 14, 69)

		merchantItemPoint()
	end)

	hooksecurefunc('MerchantFrame_UpdateBuybackInfo', function()
		local numBuybackItems = GetNumBuybackItems()
		local button, name, quality

		for i = 1, _G.BUYBACK_ITEMS_PER_PAGE do
			if i <= numBuybackItems then
				local itemName = GetBuybackItemInfo(i)

				if itemName then
					button = _G['MerchantItem'..i..'ItemButton']
					name = _G['MerchantItem'..i..'Name']
					quality = select(3, GetItemInfo(itemName))

					if quality and quality > 1 then
						local r, g, b = GetItemQualityColor(quality)
						button:SetBackdropBorderColor(r, g, b)
						name:SetTextColor(r, g, b)
					else
						button:SetBackdropBorderColor(unpack(E.media.bordercolor))
						name:SetTextColor(1, 1, 1)
					end
				end
			end
		end

		merchantItemPoint()
	end)
end

S:AddCallback('Skin_Merchant', LoadSkin)
