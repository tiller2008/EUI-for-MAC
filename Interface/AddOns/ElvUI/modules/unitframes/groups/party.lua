local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');
local _, ns = ...
local ElvUF = ns.oUF
assert(ElvUF, "ElvUI was unable to locate oUF.")

--Lua functions
local _G = _G
--WoW API / Variables
local CreateFrame = CreateFrame
local GetInstanceInfo = GetInstanceInfo
local InCombatLockdown = InCombatLockdown
local RegisterStateDriver = RegisterStateDriver
local UnregisterStateDriver = UnregisterStateDriver

function UF:Construct_PartyFrames()
	self:SetScript('OnEnter', _G.UnitFrame_OnEnter)
	self:SetScript('OnLeave', _G.UnitFrame_OnLeave)

	self.RaisedElementParent = CreateFrame('Frame', nil, self)
	self.RaisedElementParent.TextureParent = CreateFrame('Frame', nil, self.RaisedElementParent)
	self.RaisedElementParent:SetFrameLevel(self:GetFrameLevel() + 100)
	self.BORDER = E.Border
	self.SPACING = E.Spacing
	self.SHADOW_SPACING = 3

	if E.db["clickset"].enable then
		self.ClickSet = E.db["clickset"]
	end

	if self.isChild then
		self.Health = UF:Construct_HealthBar(self, true)
		self.MouseGlow = UF:Construct_MouseGlow(self)
		self.TargetGlow = UF:Construct_TargetGlow(self)
		self.Name = UF:Construct_NameText(self)
		self.RaidTargetIndicator = UF:Construct_RaidIcon(self)

		self.originalParent = self:GetParent()

		self.childType = "pet"
		if self == _G[self.originalParent:GetName()..'Target'] then
			self.childType = "target"
		end

		self.unitframeType = "party"..self.childType
	else
		self.Health = UF:Construct_HealthBar(self, true, true, 'RIGHT')
		self.Power = UF:Construct_PowerBar(self, true, true, 'LEFT')
		self.Power.frequentUpdates = false;
		self.PowerPrediction = UF:Construct_PowerPrediction(self)

		self.Portrait3D = UF:Construct_Portrait(self, 'model')
		self.Portrait2D = UF:Construct_Portrait(self, 'texture')
		self.InfoPanel = UF:Construct_InfoPanel(self)
		self.Name = UF:Construct_NameText(self)
		self.Buffs = UF:Construct_Buffs(self)
		self.Debuffs = UF:Construct_Debuffs(self)
		self.AuraWatch = UF:Construct_AuraWatch(self)
		self.RaidDebuffs = UF:Construct_RaidDebuffs(self)
		self.DebuffHighlight = UF:Construct_DebuffHighlight(self)
		self.RaidRoleFramesAnchor = UF:Construct_RaidRoleFrames(self)
		self.ResurrectIndicator = UF:Construct_ResurrectionIcon(self)
		self.MouseGlow = UF:Construct_MouseGlow(self)
		self.PhaseIndicator = UF:Construct_PhaseIcon(self)
		self.TargetGlow = UF:Construct_TargetGlow(self)
		self.RaidTargetIndicator = UF:Construct_RaidIcon(self)
		self.ReadyCheckIndicator = UF:Construct_ReadyCheckIcon(self)
		self.HealthPrediction = UF:Construct_HealComm(self)
		self.customTexts = {}

		self.Sparkle = CreateFrame("Frame", nil, self)
		self.Sparkle:SetAllPoints(self.Health)

		self.unitframeType = "party"
	end

	self.Fader = UF:Construct_Fader()
	self.Cutaway = UF:Construct_Cutaway(self)

	return self
end

function UF:Update_PartyHeader(header, db)
	header.db = db

	local headerHolder = header:GetParent()
	headerHolder.db = db

	if not headerHolder.positioned then
		headerHolder:ClearAllPoints()
		headerHolder:Point("BOTTOMLEFT", E.UIParent, "BOTTOMLEFT", 4, 225)

		E:CreateMover(headerHolder, headerHolder:GetName()..'Mover', L["Party Frames"], nil, nil, nil, 'ALL,PARTY', nil, 'unitframe,party,generalGroup')
		headerHolder.positioned = true;

		headerHolder:RegisterEvent("PLAYER_ENTERING_WORLD")
		headerHolder:RegisterEvent("ZONE_CHANGED_NEW_AREA")
		headerHolder:SetScript("OnEvent", UF.PartySmartVisibility)
	end

	UF.PartySmartVisibility(headerHolder)
end

function UF:PartySmartVisibility(event)
	if not self.db or (self.db and not self.db.enable) or (UF.db and not UF.db.smartRaidFilter) or self.isForced then
		self.blockVisibilityChanges = false
		return
	end

	if event == "PLAYER_REGEN_ENABLED" then
		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	end

	if not InCombatLockdown() then
		local _, instanceType = GetInstanceInfo()
		if instanceType == "raid" or instanceType == "pvp" then
			UnregisterStateDriver(self, "visibility")
			self.blockVisibilityChanges = true
			self:Hide()
		elseif self.db.visibility then
			RegisterStateDriver(self, "visibility", self.db.visibility)
			self.blockVisibilityChanges = false
		end
	else
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
	end
end

function UF:Update_PartyFrames(frame, db)
	frame.db = db

	frame.Portrait = frame.Portrait or (db.portrait.style == '2D' and frame.Portrait2D or frame.Portrait3D)
	frame.colors = ElvUF.colors
	frame:RegisterForClicks(self.db.targetOnMouseDown and 'AnyDown' or 'AnyUp')

	do
		if(self.thinBorders) then
			frame.SPACING = 0
			frame.BORDER = E.mult
		else
			frame.BORDER = E.Border
			frame.SPACING = E.Spacing
		end

		frame.ORIENTATION = db.orientation --allow this value to change when unitframes position changes on screen?
		frame.UNIT_WIDTH = db.width
		frame.UNIT_HEIGHT = db.infoPanel.enable and (db.height + db.infoPanel.height) or db.height

		frame.USE_POWERBAR = db.power.enable
		frame.POWERBAR_DETACHED = db.power.detachFromFrame
		frame.USE_INSET_POWERBAR = not frame.POWERBAR_DETACHED and db.power.width == 'inset' and frame.USE_POWERBAR
		frame.USE_MINI_POWERBAR = (not frame.POWERBAR_DETACHED and db.power.width == 'spaced' and frame.USE_POWERBAR)
		frame.USE_POWERBAR_OFFSET = db.power.offset ~= 0 and frame.USE_POWERBAR and not frame.POWERBAR_DETACHED
		frame.POWERBAR_OFFSET = frame.USE_POWERBAR_OFFSET and db.power.offset or 0

		frame.POWERBAR_HEIGHT = not frame.USE_POWERBAR and 0 or db.power.height
		frame.POWERBAR_WIDTH = frame.USE_MINI_POWERBAR and (frame.UNIT_WIDTH - (frame.BORDER*2))/2 or (frame.POWERBAR_DETACHED and db.power.detachedWidth or (frame.UNIT_WIDTH - ((frame.BORDER+frame.SPACING)*2)))

		frame.USE_PORTRAIT = db.portrait and db.portrait.enable
		frame.USE_PORTRAIT_OVERLAY = frame.USE_PORTRAIT and (db.portrait.overlay or frame.ORIENTATION == "MIDDLE")
		frame.PORTRAIT_WIDTH = (frame.USE_PORTRAIT_OVERLAY or not frame.USE_PORTRAIT) and 0 or db.portrait.width
		frame.CLASSBAR_YOFFSET = 0

		frame.USE_INFO_PANEL = not frame.USE_MINI_POWERBAR and not frame.USE_POWERBAR_OFFSET and db.infoPanel.enable
		frame.INFO_PANEL_HEIGHT = frame.USE_INFO_PANEL and db.infoPanel.height or 0

		frame.BOTTOM_OFFSET = UF:GetHealthBottomOffset(frame)

		frame.VARIABLES_SET = true
	end

	if frame.isChild then
		frame.USE_PORTAIT = false
		frame.USE_PORTRAIT_OVERLAY = false
		frame.PORTRAIT_WIDTH = 0
		frame.USE_POWERBAR = false
		frame.USE_INSET_POWERBAR = false
		frame.USE_MINI_POWERBAR = false
		frame.USE_POWERBAR_OFFSET = false
		frame.POWERBAR_OFFSET = 0

		frame.POWERBAR_HEIGHT = 0
		frame.POWERBAR_WIDTH = 0

		frame.BOTTOM_OFFSET = 0

		local childDB = db.petsGroup
		if frame.childType == "target" then
			childDB = db.targetsGroup
		end

		if not frame.originalParent.childList then
			frame.originalParent.childList = {}
		end
		frame.originalParent.childList[frame] = true;

		if not InCombatLockdown() then
			if childDB.enable then
				frame:SetParent(frame.originalParent)
				frame:Size(childDB.width, childDB.height)
				frame:ClearAllPoints()
				frame:Point(E.InversePoints[childDB.anchorPoint], frame.originalParent, childDB.anchorPoint, childDB.xOffset, childDB.yOffset)
			else
				frame:SetParent(E.HiddenFrame)
			end
		end

		--Health
		UF:Configure_HealthBar(frame)

		UF:Configure_RaidIcon(frame)

		--Name
		UF:UpdateNameSettings(frame, frame.childType)
	else
		if not InCombatLockdown() then
			frame:Size(frame.UNIT_WIDTH, frame.UNIT_HEIGHT)
		end

		UF:Configure_InfoPanel(frame)
		UF:Configure_HealthBar(frame)

		UF:UpdateNameSettings(frame)

		UF:Configure_PhaseIcon(frame)

		UF:Configure_Power(frame)

		-- Power Predicition
		UF:Configure_PowerPrediction(frame)

		UF:Configure_Portrait(frame)

		UF:EnableDisable_Auras(frame)
		UF:Configure_Auras(frame, 'Buffs')
		UF:Configure_Auras(frame, 'Debuffs')

		UF:Configure_ResurrectionIcon(frame)

		UF:Configure_RaidDebuffs(frame)

		UF:Configure_RaidIcon(frame)

		UF:Configure_DebuffHighlight(frame)

		UF:Configure_HealComm(frame)

		UF:Configure_RaidRoleIcons(frame)

		UF:Configure_AuraWatch(frame)

		UF:Configure_ReadyCheckIcon(frame)

		UF:Configure_CustomTexts(frame)
	end

	--Fader
	UF:Configure_Fader(frame)

	--Cutaway
	UF:Configure_Cutaway(frame)

	frame:UpdateAllElements("ElvUI_UpdateAllElements")
end

UF.headerstoload.party = {nil, 'ELVUI_UNITPET, ELVUI_UNITTARGET'}
