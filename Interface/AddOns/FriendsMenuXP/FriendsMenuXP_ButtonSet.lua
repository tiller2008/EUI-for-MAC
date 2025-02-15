--[[
-- 对右键菜单来说, 继承UIDropDownTemplate意义不大, 只是作为一个容器在用, Button和Text都不会显示出来
--]]

--[[
	text,                                              --按钮名称
	textHeight,                                        --按钮字体大小
	icon,                                              --按钮图片路径
	tCoordLeft, tCoordRight, tCoordTop, tCoordBottom,  --按钮图片的相对部分
	textR, textG, textB,                               --按钮文字顔色
	tooltipText,                                       --提示信息
	show,                                              --判断是否显示该按钮的函数
	func,                                              --点击按钮所进行的操作
	notClickable,                                      --不可点击(灰色按钮)
	justifyH,                                          --文字对其方式, LEFT或CENTER
	isSecure,                                          --是否是安全按钮
	attributes,                                        --安全按钮的属性, 格式为"属性1:值1; 属性2:值2"
]]

--{ "WHISPER", "INVITE", "TARGET", "IGNORE", "REPORT_SPAM", "GUILD_PROMOTE", "GUILD_LEAVE", "CANCEL" };
function NoSelfShow(name) return UnitName("player")~=name; end

FriendsMenuXP_Buttons = {};

FriendsMenuXP_Buttons["WHISPER"] = {
    text = WHISPER,
    func = function(name) ChatFrame_SendTell(name); end,
    --show = NoSelfShow,
}

FriendsMenuXP_Buttons["POP_OUT_CHAT"] = {
    text = POP_OUT_CHAT,
    func = function(name)
        ChatFrame_SendTell(name); end,
    --show = NoSelfShow,
}

FriendsMenuXP_Buttons["INVITE"] = {
    text = PARTY_INVITE,
    func = function(name) InviteUnit(name); end,
    show = NoSelfShow,
}

FriendsMenuXP_Buttons["TARGET"] = {
    text = TARGET,
    isSecure = 1,
    attributes = "type:macro;macrotext:/targetexact $name$",
    func = function(name)
        if(UnitName("target")~=name and GetUnitName("target", true)~=name) then
            DEFAULT_CHAT_FRAME:AddMessage(string.gsub(FRIENDS_MENU_XP_CANNOT_TARGET, "%$name%$", name), 1,1,0);
        end
    end,
}

FriendsMenuXP_Buttons["IGNORE"] = {
    text = IGNORE,
    func = function(name) C_FriendList.AddOrDelIgnore(name); end,
    show = function(name)
        if(name == UnitName("player")) then return end;
        for i = 1, C_FriendList.GetNumIgnores() do
            if(name == C_FriendList.GetIgnoreName(i)) then
                return nil;
            end
        end
        return 1;
    end,
}

FriendsMenuXP_Buttons["CANCEL_IGNORE"] = {
    text = CANCEL..IGNORE,
    func = function(name) C_FriendList.AddOrDelIgnore(name); end,
    show = function(name)
        if(name == UnitName("player")) then return end;
        for i = 1, C_FriendList.GetNumIgnores() do
            if(name == C_FriendList.GetIgnoreName(i)) then
                return 1;
            end
        end
    end,
}

--classic ["REPORT_PLAYER"] = { "REPORT_SPAMMING", "REPORT_BAD_LANGUAGE", "REPORT_ABUSE", "REPORT_BAD_NAME", "REPORT_BAD_GUILD_NAME", "REPORT_PET_NAME", "REPORT_CHEATING" },
--https://github.com/Gethe/wow-ui-source/blob/classic/FrameXML/StaticPopupSpecial.lua
FriendsMenuXP_Buttons["REPORT_SPAMMING"] = {
    text = FMXP_BUTTON_REPORT_PLAYER_FOR..REPORT_SPAMMING,
    func = function(name, dropdown)
        local dialog = StaticPopup_Show("PLAYER_REPORT_TYPE_SPAM", name);
        if ( dialog ) then
            dialog.data = dropdown.unit or tonumber(dropdown.lineID);
        end
    end,
    show = function(name, dropdown) return dropdown.lineID end,--and CanComplainChat(dropdown.lineID) end,
}

FriendsMenuXP_Buttons["REPORT_BAD_LANGUAGE"] = {
    text = FMXP_BUTTON_REPORT_PLAYER_FOR..REPORT_BAD_LANGUAGE,
    func = function(name, dropdown)
        local dialog = StaticPopup_Show("PLAYER_REPORT_TYPE_LANGUAGE", name);
        if ( dialog ) then
            dialog.data = dropdown.unit or tonumber(dropdown.lineID);
        end
    end,
    show = function(name, dropdown) return dropdown.lineID end,--and CanComplainChat(dropdown.lineID) end,
}

FriendsMenuXP_Buttons["REPORT_BAD_NAME"] = {
    text = FMXP_BUTTON_REPORT_PLAYER_FOR..REPORT_BAD_NAME,
    func = function(name, dropdown)
        local dialog = StaticPopup_Show("PLAYER_REPORT_TYPE_BAD_PLAYER_NAME", name);
        if ( dialog ) then
            dialog.data = dropdown.unit or tonumber(dropdown.lineID);
        end
    end,
    show = function(name, dropdown) return dropdown.lineID end, --and CanComplainChat(dropdown.lineID) end,
}

FriendsMenuXP_Buttons["REPORT_CHEATING"] = {
    text = FMXP_BUTTON_REPORT_PLAYER_FOR..REPORT_CHEATING,
    func = function(name, dropdown)
        local dialog = StaticPopup_Show("PLAYER_REPORT_TYPE_CHEATING", name);
        if ( dialog ) then
            dialog.data = dropdown.unit or tonumber(dropdown.lineID);
        end
    end,
    show = function(name, dropdown) return dropdown.lineID end,--and CanComplainChat(dropdown.lineID) end,
}

FriendsMenuXP_Buttons["CANCEL"] = {
    text = CANCEL,
}

FriendsMenuXP_Buttons["ADD_FRIEND"] = {
    text = FMXP_BUTTON_ADD_FRIEND,
    func = function (name) C_FriendList.AddFriend(name); end,
    show = function(name)
        if(name == UnitName("player")) then return end;
        for i = 1, C_FriendList.GetNumFriends() do
            local f = C_FriendList.GetFriendInfoByIndex(i)
            if(name == f.name) then
                return nil;
            end
        end
        return 1;
    end,
}

FriendsMenuXP_Buttons["REMOVE_FRIEND"] = {
    text = REMOVE_FRIEND,
    func = function (name) C_FriendList.RemoveFriend(name); end,
    show = function(name)
        if(name == UnitName("player")) then return end;
        for i = 1, C_FriendList.GetNumFriends() do
            local f = C_FriendList.GetFriendInfoByIndex(i)
            if(name == f.name) then
                return true;
            end
        end
    end,
}

FriendsMenuXP_Buttons["SET_NOTE"] = {
    text = SET_NOTE,
    func = function (name)
        FriendsFrame.NotesID = name;
        StaticPopup_Show("SET_FRIENDNOTE", name);
        PlaySound(163);
    end,
    show = function(name)
        if(name == UnitName("player")) then return end;
        for i = 1, C_FriendList.GetNumFriends() do
            local f = C_FriendList.GetFriendInfoByIndex(i)
            if(name == f.name) then
                return true;
            end
        end
    end,
}

FriendsMenuXP_Buttons["GUILD_LEAVE"] = {
    text = GUILD_LEAVE,
    func = function (name) StaticPopup_Show("CONFIRM_GUILD_LEAVE", GetGuildInfo("player")); end,
    show = function(name)
        if name ~= UnitName("player") or (GuildFrame and not GuildFrame:IsShown()) then return end;
        return 1;
    end,
}

FriendsMenuXP_Buttons["GUILD_PROMOTE"] = {
    text = GUILD_PROMOTE,
    func = function (name) local dialog = StaticPopup_Show("CONFIRM_GUILD_PROMOTE", name); dialog.data = name; end,
    show = function(name)
        if ( not IsGuildLeader() or not UnitIsInMyGuild(name) or name == UnitName("player") or (GuildFrame and not GuildFrame:IsShown()) ) then return end;
        return 1;
    end,
}

FriendsMenuXP_Buttons["REPORT_SUGGESTION"] = {
    text = REPORT_SUGGESTION,
    func = function (name) ReportSuggestion(name); end,
    show = function(name)
        return 1;
    end,
}

FriendsMenuXP_Buttons["PVP_REPORT_AFK"] = {
    text = PVP_REPORT_AFK,
    func = function (name) ReportPlayerIsPVPAFK(name); end,
    show = function(name)
        if ( UnitInBattleground("player") == 0 or GetCVar("enablePVPNotifyAFK") == "0" ) then
            return;
        else
            if ( name == UnitName("player") ) then
                return;
            elseif ( not UnitInBattleground(name) ) then
                return;
            end
        end
        return 1;
    end,
}

FriendsMenuXP_Buttons["SET_FOCUS"] = {
    text = SET_FOCUS,
    isSecure = 1,
    attributes = "type:macro;macrotext:/targetexact $name$\n/focus\n/targetlasttarget",
}

FriendsMenuXP_Buttons["PROMOTE"] = {
    text = PARTY_PROMOTE,
    func = function (name) PromoteToLeader(name, 1); end,
    show = function (name)
        if (GetNumGroupMembers() > 0 and (UnitIsGroupLeader("player") or UnitIsGroupAssistant("player"))) then
            return 1
        end
    end,
}

FriendsMenuXP_Buttons["LOOT_PROMOTE"] = {
    text = LOOT_PROMOTE,
    func = function (name) SetLootMethod("master", name, 1); end,
    show = function (name)
        if (GetNumGroupMembers() > 0 and (UnitIsGroupLeader("player") or UnitIsGroupAssistant("player"))) then
            return 1
        end
    end,
}

FriendsMenuXP_Buttons["ACHIEVEMENTS"] = {
    text = FMXP_BUTTON_ACHIEVEMENTS,
    func = function (name) InspectAchievements(name); end,
}

FriendsMenuXP_Buttons["SEND_WHO"] = {
    text = FMXP_BUTTON_SEND_WHO,
    func = function (name) C_FriendList.SendWho("n-"..name); end,
}

FriendsMenuXP_Buttons["ADD_GUILD"] = {
    text = FMXP_BUTTON_ADD_GUILD,
    func = function (name) GuildInvite(name); end,
    show = function (name) return name~=UnitName("player") and CanGuildInvite() end,
}

FriendsMenuXP_Buttons["GET_NAME"] = {
    text = FMXP_BUTTON_GET_NAME,
    func = function (name)
        if ( SendMailNameEditBox and SendMailNameEditBox:IsVisible() ) then
            SendMailNameEditBox:SetText(name);
            SendMailNameEditBox:HighlightText();
        elseif( CT_MailNameEditBox and CT_MailNameEditBox:IsVisible() ) then
            CT_MailNameEditBox:SetText(name);
            CT_MailNameEditBox:HighlightText();
        else
            local editBox = ChatEdit_ChooseBoxForSend();
            if editBox:HasFocus() then
                editBox:Insert(name);
            else
                ChatEdit_ActivateChat(editBox);
                editBox:SetText(name);
                editBox:HighlightText();
            end
        end
    end,
}

FriendsMenuXP_Buttons["TRADE"] = {
    text = TRADE,
    isSecure = 1,
    attributes = "type:macro;macrotext:/targetexact $name$",
    func = function (name) InitiateTrade("target"); end,
}

FriendsMenuXP_Buttons["Chat_BlackName"] = {
	text = FMXP_BUTTON_CHAT_BLACKLIST,
	show = function(name)
		if not ElvUI then 
			DEFAULT_CHAT_FRAME:AddMessage('Not find EUI!',1,1,0);
			return;
		end
		if ElvUI[1].global.InfoFilter.blackName[name] then
			return false;
		else
			return true;
		end
	end,
	func = function(name, dropdownFrame)
		if not ElvUI then 
			DEFAULT_CHAT_FRAME:AddMessage('Not find EUI!',1,1,0);
			return;
		end
		if not name:find('-') then
			name = name..'-'..ElvUI[1].myrealm
		end
		ElvUI[1].global.InfoFilter.blackName[name] = true
		DEFAULT_CHAT_FRAME:AddMessage(name.. FMXP_BUTTON_CHAT_BLACKLIST_INTRO,1,1,0);
		if IsAddOnLoaded('ElvUI_Config') then
			for k, v in pairs(ElvUI[1].global.InfoFilter.blackName) do
				ElvUI[1].Options.args.InfoFilter.args.blackName.args.List.values[k] = k
			end
		end
	end,
}

--智力
FriendsMenuXP_Buttons["SPELL_MAGE_INTELLECT"] = {
    spellId = 1459,
};

--魔法凝聚
FriendsMenuXP_Buttons["SPELL_MAGE_FOCUS_MAGIC"] = {
    spellId = 54646,
};

--耐力
FriendsMenuXP_Buttons["SPELL_PRIEST_FORTITUDE"] = {
    spellId = 21562,
};

--防护暗影
FriendsMenuXP_Buttons["SPELL_PRIEST_SHADOW"] = {
    spellId = 27683,
};

--爪子
FriendsMenuXP_Buttons["SPELL_DRUID_MILD"] = {
    spellId =  1126,
};

FriendsMenuXP_Buttons["SPELL_PAL_MIGHT"] = {
    spellId = 19740,
};

FriendsMenuXP_Buttons["SPELL_PAL_KINGS"] = {
    spellId = 20217,
};

FriendsMenuXP_Buttons["SPELL_WARLOCK_DARK_INTENT"] = {
    spellId = 80398,
};

local function urlencode(obj)
    local currentIndex = 1;
    local charArray = {}
    while currentIndex <= #obj do
        local char = string.byte(obj, currentIndex);
        charArray[currentIndex] = char
        currentIndex = currentIndex + 1
    end
    local converchar = "";
    for _, char in ipairs(charArray) do
        converchar = converchar..string.format("%%%X", char)
    end
    return converchar;
end

FriendsMenuXP_Buttons["ARMORY"] = {
    text = FMXP_BUTTON_ARMORY,
    func = function(name)
        local n,r = name:match"(.*)-(.*)"
        n = n or name
        r = r or GetRealmName()

        local portal = GetCVar'portal'
        local host = portal == 'cn' and "http://www.battlenet.com.cn/" or ("http://%s.battle.net/"):format(GetCVar'portal')

        local armory = host.."wow/character/"..urlencode(r).."/"..urlencode(n).."/advanced"
        local armoryNoDecode = host.."wow/character/"..r.."/"..n.."/advanced"

        if ThreeDimensionsCode_Send and Cmd3DCode_CheckoutClientAndPrompt and not IsControlKeyDown() and Cmd3DCode_CheckoutClientAndPrompt("没有检测到有爱客户端，无法启动有爱内置浏览器，请手工复制网址") then
            U1Message(format("已在内置浏览器中打开英雄榜，下次按住CTRL可以获取链接。"))
            ThreeDimensionsCode_Send("innerbrowser",armoryNoDecode)
        else
            local editBox = ChatEdit_ChooseBoxForSend();
            ChatEdit_ActivateChat(editBox);
            editBox:SetText(armory);
            editBox:HighlightText();
        end
    end,
}

FriendsMenuXP_Buttons["POP_OUT_CHAT"] = {
    text = POP_OUT_CHAT,
    show = function(name, dropdownMenu)
        if ( (dropdownMenu.chatType ~= "WHISPER" and dropdownMenu.chatType ~= "BN_WHISPER") or dropdownMenu.chatTarget == UnitName("player") or
                FCFManager_GetNumDedicatedFrames(dropdownMenu.chatType, dropdownMenu.chatTarget) > 0 ) then
            return false
        end
        return true
    end,
    func = function(name, dropdownFrame)
        FCF_OpenTemporaryWindow(dropdownFrame.chatType, dropdownFrame.chatTarget, dropdownFrame.chatFrame, true);
    end,
}

local _
for k,v in pairs(FriendsMenuXP_Buttons) do
    v.justifyH = "LEFT"
    if v.spellId then
        v.text, _, v.icon = GetSpellInfo(v.spellId);
        if(v.text)then
            v.textHeight = 12
            v.isSecure = 1
            v.attributes = "type:macro;macrotext:/targetexact $name$\n/cast "..v.text:gsub("%:","%^").."\n/targetlasttarget"
            v.show = function() return IsSpellKnown(v.spellId) end
        else
            v.show = function() return false end
        end
    end
end

FriendsMenuXP_ButtonSet = {};
FriendsMenuXP_ButtonSet["NORMAL"] = {
    "WHISPER",
    "POP_OUT_CHAT",
    "INVITE",
    "TARGET",
    "SET_NOTE",
    "REPORT_SPAMMING",
    "REPORT_BAD_LANGUAGE",
    "IGNORE",
    "CANCEL_IGNORE",
    "PROMOTE",
    "LOOT_PROMOTE",
    --"REPORT_BAD_NAME",
    --"REPORT_CHEATING",
    "GUILD_LEAVE",
    "GUILD_PROMOTE",
    "PVP_REPORT_AFK",
    "REMOVE_FRIEND",
    "ADD_FRIEND",
    "ADD_GUILD",
    --"SET_FOCUS",
    "SEND_WHO",
    "GET_NAME",
    "TRADE",
    --"ACHIEVEMENTS",
    --"ARMORY",
	"Chat_BlackName",
    "CANCEL",
}

FriendsMenuXP_ButtonSet["RAID"] = {
    "WHISPER",
    "TARGET",
    "SEND_WHO",
    "GET_NAME",
    "TRADE",
    "PROMOTE",
    "LOOT_PROMOTE",
    --"SET_FOCUS",
    --"ACHIEVEMENTS",
    --"ARMORY",
    "CANCEL",
}

FriendsMenuXP_ButtonSet["OFFLINE"] = {
    "SET_NOTE",
    "IGNORE",
    "CANCEL_IGNORE",
    "ADD_FRIEND",
    "REMOVE_FRIEND",
    --"ARMORY",
    "CANCEL",
}

FriendsMenuXP_ButtonSet["UNITPOPUP"] = {
    "REMOVE_FRIEND",
    "SET_NOTE",
    "ADD_GUILD",
    "GET_NAME",
    --"ARMORY",
    "IGNORE",
    "CANCEL_IGNORE",
}

FriendsMenuXP_ButtonSet["NPC"] = {
    "GET_NAME",
}