  local a = CreateFrame("Frame")

  a:SetScript("OnEvent", function(self, event)
    if(event=="PLAYER_LOGIN") then
		local bcq = _G["CombatLogQuickButtonFrame_Custom"]
		bcq:Hide()
		bcq:HookScript("OnShow", function(s) s:Hide(); end)
		bcq:SetHeight(0)
    end
  end)
  
  a:RegisterEvent("PLAYER_LOGIN")


if (Prat or ChatMOD_Loaded or ChatSync or Chatter or PhanxChatDB) then return; end
local addon = LibStub("AceAddon-3.0"):GetAddon("SpartanUI");
local module = addon:NewModule("ChatFrame");
---------------------------------------------------------------------------

function module:OnEnable()


	local origSetItemRef = SetItemRef
	SetItemRef = function(link, text, button)
	  local linkType = string.sub(link, 1, 6)
	  if IsAltKeyDown() and linkType == "player" then
		local name = string.match(link, "player:([^:]+)")
		InviteUnit(name)
		return nil
	  end
	  return origSetItemRef(link,text,button)
	end
	
		  
	--guild
	CHAT_GUILD_GET = "|Hchannel:GUILD|hG|h %s "
	CHAT_OFFICER_GET = "|Hchannel:OFFICER|hO|h %s "

	--raid
	CHAT_RAID_GET = "|Hchannel:RAID|hR|h %s "
	CHAT_RAID_WARNING_GET = "RW %s "
	CHAT_RAID_LEADER_GET = "|Hchannel:RAID|hRL|h %s "

	--party
	CHAT_PARTY_GET = "|Hchannel:PARTY|hP|h %s "
	CHAT_PARTY_LEADER_GET =  "|Hchannel:PARTY|hPL|h %s "
	CHAT_PARTY_GUIDE_GET =  "|Hchannel:PARTY|hPG|h %s "

	--bg
	CHAT_BATTLEGROUND_GET = "|Hchannel:BATTLEGROUND|hB|h %s "
	CHAT_BATTLEGROUND_LEADER_GET = "|Hchannel:BATTLEGROUND|hBL|h %s "

	--whisper  
	CHAT_WHISPER_INFORM_GET = "to %s "
	CHAT_WHISPER_GET = "from %s "
	CHAT_BN_WHISPER_INFORM_GET = "to %s "
	CHAT_BN_WHISPER_GET = "from %s "

	--say / yell
	CHAT_SAY_GET = "%s "
	CHAT_YELL_GET = "%s "

	--flags
	CHAT_FLAG_AFK = "[AFK] "
	CHAT_FLAG_DND = "[DND] "
	CHAT_FLAG_GM = "[GM] "

	local gsub = _G.string.gsub

	for i = 1, NUM_CHAT_WINDOWS do
		if ( i ~= 2 ) then
			local f = _G["ChatFrame"..i]
			local am = f.AddMessage
			f.AddMessage = function(frame, text, ...)
			return am(frame, text:gsub('|h%[(%d+)%. .-%]|h', '|h%1|h'), ...)
			end
		end
	end 

	-- // rChat
	-- // zork - 2010

	-----------------------------
	-- INIT
	-----------------------------

	local _G = _G

	-----------------------------
	-- FUNCTIONS
	-----------------------------

	for i = 1, 23 do
		CHAT_FONT_HEIGHTS[i] = i+7
	end

	for i = 1, NUM_CHAT_WINDOWS do
		local bf = _G['ChatFrame'..i..'ButtonFrame']
			if bf then 
				bf:Hide() 
				bf:HookScript("OnShow", function(s) s:Hide(); end)
			end
		local ebtl = _G['ChatFrame'..i..'EditBoxLeft']
		if ebtl then ebtl:Hide() end
		local ebtm = _G['ChatFrame'..i..'EditBoxMid']
		if ebtm then ebtm:Hide() end      
		local ebtr = _G['ChatFrame'..i..'EditBoxRight']
		if ebtr then ebtr:Hide() end
		local cf = _G['ChatFrame'..i]
		if cf then 
			if i == 2 then
				cf:SetJustifyH("RIGHT");
			end
			cf:SetFont(NAMEPLATE_FONT, 12, "THINOUTLINE") 
			cf:SetShadowOffset(1,-1)
			cf:SetShadowColor(0,0,0,0.6)
			cf:SetFrameStrata("LOW")
			cf:SetFrameLevel(2)
			cf:SetClampedToScreen(false)
		end
		local eb = _G['ChatFrame'..i..'EditBox']
		if eb and cf then
			cf:SetClampRectInsets(0,0,0,0)
			--cf:SetFading(false)
			eb:SetAltArrowKeyMode(false)
			eb:ClearAllPoints()
			eb:SetPoint("BOTTOM",cf,"TOP",0,22)
			eb:SetPoint("LEFT",cf,-5,0)
			eb:SetPoint("RIGHT",cf,10,0)
		end
		local tab = _G['ChatFrame'..i..'Tab']
		if tab then
			tab:GetFontString():SetFont(NAMEPLATE_FONT, 11, "THINOUTLINE")
			--fix for color and alpha of undocked frames
			tab:GetFontString():SetTextColor(1,0.7,0)
			tab:GetFontString():SetShadowOffset(1,-1)
			tab:GetFontString():SetShadowColor(0,0,0,0.6)
			tab:SetAlpha(1)
		end
	end


	local mb = _G['ChatFrameMenuButton']
	if mb then 
		mb:Hide() 
		mb:HookScript("OnShow", function(mb) mb:Hide(); end)
	end

	local fmb = _G['FriendsMicroButton']
--	if fmb then 
		fmb:Hide()
		fmb:HookScript("OnShow", function(fmb) fmb:Hide(); end)
--	end

	ChatFontNormal:SetFont(NAMEPLATE_FONT, 12, "THINOUTLINE") 
	ChatFontNormal:SetShadowOffset(1,-1)
	ChatFontNormal:SetShadowColor(0,0,0,0.6)

	
  ------------------------------------
  -- CONFIG
  -----------------------------------
  
  local hide_chattab_backgrounds = true
  local not_selected_tab_alpha = 0.4
  
  ------------------------------------
  -- CONFIG END
  -----------------------------------  

  CHAT_TAB_SHOW_DELAY = 0
  CHAT_TAB_HIDE_DELAY = 0
  
  CHAT_FRAME_TAB_SELECTED_MOUSEOVER_ALPHA = 1
  CHAT_FRAME_TAB_SELECTED_NOMOUSE_ALPHA = 1
  CHAT_FRAME_TAB_ALERTING_MOUSEOVER_ALPHA = 1
  CHAT_FRAME_TAB_ALERTING_NOMOUSE_ALPHA = 1
  CHAT_FRAME_TAB_NORMAL_MOUSEOVER_ALPHA = 1
  CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA = 1
  
  DEFAULT_CHATFRAME_ALPHA = 0

  if hide_chattab_backgrounds then
  
    local _G = _G
    
    local TAB_TEXTURES = {
      "Left",
      "Middle",
      "Right",
      "SelectedLeft",
      "SelectedMiddle",
      "SelectedRight",
      "Glow",
      "HighlightLeft",
      "HighlightMiddle",
      "HighlightRight",
    }
  
    --disable all tab textures
    for i = 1, NUM_CHAT_WINDOWS do
      for index, value in pairs(TAB_TEXTURES) do
        local texture = _G['ChatFrame'..i..'Tab'..value]
        texture:SetTexture(nil)
      end
    end
  end

  --disable tab flashing
  FCF_FlashTab = function() end
  FCFTab_UpdateAlpha = function() end

  --new fadein func
  FCF_FadeInChatFrame = function(chatFrame)
    chatFrame.hasBeenFaded = true  
  end

  --new fadeout func
  FCF_FadeOutChatFrame = function(chatFrame)
    chatFrame.hasBeenFaded = false
  end    
  
  FCFTab_UpdateColors = function(self, selected)
    if (selected) then
      self:GetFontString():SetTextColor(1,0.7,0)
      self:GetFontString():SetShadowOffset(1,-1)
      self:GetFontString():SetShadowColor(0,0,0,0.6)
      self:SetAlpha(1)
      self.leftSelectedTexture:Show();
      self.middleSelectedTexture:Show();
      self.rightSelectedTexture:Show();
    else
      self:GetFontString():SetTextColor(0.5,0.5,0.5)
      self:GetFontString():SetShadowOffset(1,-1)
      self:GetFontString():SetShadowColor(0,0,0,0.3)
      self:SetAlpha(not_selected_tab_alpha)
      self.leftSelectedTexture:Hide();
      self.middleSelectedTexture:Hide();
      self.rightSelectedTexture:Hide();
    end
  end

  FloatingChatFrame_OnMouseScroll = function(self, dir)
  if(dir > 0) then
    if(IsShiftKeyDown()) then
      self:ScrollToTop()
    else
      self:ScrollUp()
    end
  else
    if(IsShiftKeyDown()) then
      self:ScrollToBottom()
    else
      self:ScrollDown()
    end
  end
end


  local color = "0099FF"
  local foundurl = false
  
  function string.color(text, color)
    return "|cff"..color..text.."|r"
  end
  
  function string.link(text, type, value, color)
    return "|H"..type..":"..tostring(value).."|h"..tostring(text):color(color or "ffffff").."|h"
  end
  
  local function highlighturl(before,url,after)
    foundurl = true
    return " "..string.link("["..url.."]", "url", url, color).." "
  end
  
  local function searchforurl(frame, text, ...)
  
    foundurl = false
  
    if string.find(text, "%pTInterface%p+") then 
      --disable interface textures (lol)
      foundurl = true
    end
  
    if not foundurl then
      --192.168.1.1:1234
      text = string.gsub(text, "(%s?)(%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?:%d%d?%d?%d?%d?)(%s?)", highlighturl)
    end
    if not foundurl then
      --192.168.1.1
      text = string.gsub(text, "(%s?)(%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?)(%s?)", highlighturl)
    end
    if not foundurl then
      --www.teamspeak.com:3333
      text = string.gsub(text, "(%s?)([%w_-]+%.?[%w_-]+%.[%w_-]+:%d%d%d?%d?%d?)(%s?)", highlighturl)
    end
    if not foundurl then
      --http://www.google.com
      text = string.gsub(text, "(%s?)(%a+://[%w_/%.%?%%=~&-'%-]+)(%s?)", highlighturl)
    end
    if not foundurl then
      --www.google.com
      text = string.gsub(text, "(%s?)(www%.[%w_/%.%?%%=~&-'%-]+)(%s?)", highlighturl)
    end
    if not foundurl then
      --lol@lol.com
      text = string.gsub(text, "(%s?)([_%w-%.~-]+@[_%w-]+%.[_%w-%.]+)(%s?)", highlighturl)
    end
  
    frame.am(frame,text,...)
    
  end
  
  for i = 1, NUM_CHAT_WINDOWS do
    if ( i ~= 2 ) then
      local cf = _G["ChatFrame"..i]
      cf.am = cf.AddMessage
      cf.AddMessage = searchforurl
    end
  end
  
  local orig = ChatFrame_OnHyperlinkShow
  function ChatFrame_OnHyperlinkShow(frame, link, text, button)
    local type, value = link:match("(%a+):(.+)")
    if ( type == "url" ) then
      --local eb = _G[frame:GetName()..'EditBox'] --sometimes this is not the active chatbox. thus use the last active one for this
      local eb = LAST_ACTIVE_CHAT_EDIT_BOX or _G[frame:GetName()..'EditBox']
      if eb then
        eb:SetText(value)
        eb:SetFocus()
        eb:HighlightText()
      end
    else
      orig(self, link, text, button)
    end
  end


	
end

