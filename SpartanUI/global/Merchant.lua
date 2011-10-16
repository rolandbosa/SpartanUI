local function My_OnEvent(event)
	if(event=="MERCHANT_SHOW") then
		for bag=0,4 do
			for slot=0,GetContainerNumSlots(bag) do
				local link = GetContainerItemLink(bag, slot)
				if link and select(3, GetItemInfo(link)) == 0 then
					ShowMerchantSellCursor(1)
					UseContainerItem(bag, slot)
				end
			end
		end
		if (CanMerchantRepair() and not IsControlKeyDown()) then
			local repairAllCost, canRepair = GetRepairAllCost()
			if(canRepair) then
				if(CanGuildBankRepair()) then
					local guildMoney = GetGuildBankMoney()
					if(not(repairAllCost > guildMoney)) then
						RepairAllItems(1)
					elseif(repairAllCost > GetMoney()) then
						RepairAllItems(0) 
					end
				end
			end
		end
	end
end

local f = CreateFrame("Frame")

f:SetScript("OnEvent", function (self, event, ...)
	My_OnEvent(event)
	end)
f:RegisterEvent("MERCHANT_SHOW")


