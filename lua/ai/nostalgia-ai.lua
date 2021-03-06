sgs.weapon_range.MoonSpear = 3
sgs.ai_use_priority.MoonSpear = 2.635

nosjujian_skill={}
nosjujian_skill.name="nosjujian"
table.insert(sgs.ai_skills,nosjujian_skill)
nosjujian_skill.getTurnUseCard=function(self)
	if not self.player:hasUsed("NosJujianCard") then return sgs.Card_Parse("@NosJujianCard=.") end
end

sgs.ai_skill_use_func.NosJujianCard = function(card, use, self)
	local abandon_handcard = {}
	local index = 0
	local hasPeach = (self:getCardsNum("Peach") > 0)

	local trick_num, basic_num, equip_num = 0, 0, 0
	if not hasPeach and self.player:isWounded() and self.player:getHandcardNum() >=3 then
		local cards = self.player:getCards("he")
		cards=sgs.QList2Table(cards)
		self:sortByUseValue(cards, true)
		for _, card in ipairs(cards) do
			if card:getTypeId() == sgs.Card_Trick and not card:isKindOf("ExNihilo") then trick_num = trick_num + 1
			elseif card:getTypeId() == sgs.Card_Basic then basic_num = basic_num + 1
			elseif card:getTypeId() == sgs.Card_Equip then equip_num = equip_num + 1
			end
		end
		local result_class
		if trick_num >= 3 then result_class = "TrickCard"
		elseif equip_num >= 3 then result_class = "EquipCard"
		elseif basic_num >= 3 then result_class = "BasicCard"
		end
		local f
		for _, friend in ipairs(self.friends_noself) do
			if (friend:getHandcardNum()<2) or (friend:getHandcardNum()<friend:getHp()+1) and not friend:hasSkill("manjuan") then
				for _, fcard in ipairs(cards) do
					if fcard:isKindOf(result_class) and not fcard:isKindOf("ExNihilo") then
						table.insert(abandon_handcard, fcard:getId())
						index = index + 1
					end
					if index == 3 then f = friend break end
				end
			end
		end
		if index == 3 then
			if use.to then use.to:append(f) end
			use.card = sgs.Card_Parse("@NosJujianCard=" .. table.concat(abandon_handcard, "+"))
			return
		end
	end
	abandon_handcard = {}
	local cards = self.player:getHandcards()
	cards=sgs.QList2Table(cards)
	self:sortByUseValue(cards, true)
	local slash_num = self:getCardsNum("Slash")
	local jink_num = self:getCardsNum("Jink")
	for _, friend in ipairs(self.friends_noself) do
		if (friend:getHandcardNum()<2) or (friend:getHandcardNum()<friend:getHp()+1) or self.player:isWounded() then
			for _, card in ipairs(cards) do
				if #abandon_handcard >= 3 then break end
				if not card:isKindOf("Nullification") and not card:isKindOf("EquipCard") and
					not card:isKindOf("Peach") and not card:isKindOf("Jink") and
					not card:isKindOf("Indulgence") and not card:isKindOf("SupplyShortage") then
					table.insert(abandon_handcard, card:getId())
					index = 5
				elseif card:isKindOf("Slash") and slash_num > 1 then
					if (self.player:getWeapon() and not self.player:getWeapon():objectName()=="crossbow") or
						not self.player:getWeapon() then
						table.insert(abandon_handcard, card:getId())
						index = 5
						slash_num = slash_num - 1
					end
				elseif card:isKindOf("Jink") and jink_num > 1 then
					table.insert(abandon_handcard, card:getId())
					index = 5
					jink_num = jink_num - 1
				end
			end
			if index == 5 then
				use.card = sgs.Card_Parse("@NosJujianCard=" .. table.concat(abandon_handcard, "+"))
				if use.to then use.to:append(friend) end
				return
			end
		end
	end
	if #self.friends_noself>0 and self:getOverflow()>0 then
		self:sort(self.friends_noself, "handcard")
		local discard = self:askForDiscard("gamerule", math.min(self:getOverflow(),3))
		use.card = sgs.Card_Parse("@NosJujianCard=" .. table.concat(discard, "+"))
		if use.to then use.to:append(self.friends_noself[1]) end
		return
	end
end

sgs.ai_use_priority.NosJujianCard = 4.5
sgs.ai_use_value.NosJujianCard = 6.7

sgs.ai_card_intention.NosJujianCard = -100

sgs.dynamic_value.benefit.NosJujianCard = true

sgs.ai_skill_cardask["@enyuanheart"] = function(self)
	local cards = self.player:getHandcards()
	for _, card in sgs.qlist(cards) do
		if card:getSuit() == sgs.Card_Heart and not (card:isKindOf("Peach") or card:isKindOf("ExNihilo")) then
			return card:getEffectiveId()
		end
	end
	return "."
end

function sgs.ai_slash_prohibit.nosenyuan(self)
	if self:isWeak() then return true end
end

nosxuanhuo_skill={}
nosxuanhuo_skill.name="nosxuanhuo"
table.insert(sgs.ai_skills,nosxuanhuo_skill)
nosxuanhuo_skill.getTurnUseCard=function(self)
	if not self.player:hasUsed("NosXuanhuoCard") then
		return sgs.Card_Parse("@NosXuanhuoCard=.")
	end
end

sgs.ai_skill_use_func.NosXuanhuoCard = function(card, use, self)
	local cards = self.player:getHandcards()
	cards=sgs.QList2Table(cards)
	self:sortByUseValue(cards,true)

	local target
	for _, friend in ipairs(self.friends_noself) do
		if self:hasSkills(sgs.lose_equip_skill, friend) and not friend:getEquips():isEmpty() then
			for _, card in ipairs(cards) do
				if card:getSuit() == sgs.Card_Heart and self.player:getHandcardNum() > 1 then
					use.card = sgs.Card_Parse("@NosXuanhuoCard=" .. card:getEffectiveId())
					target = friend
					break
				end
			end
		end
		if target then break end
	end
	if not target then
		for _, enemy in ipairs(self.enemies) do
			if not enemy:isKongcheng() then
				for _, card in ipairs(cards)do
					if card:getSuit() == sgs.Card_Heart and not card:isKindOf("Peach") and self.player:getHandcardNum() > 1 then
						use.card = sgs.Card_Parse("@NosXuanhuoCard=" .. card:getEffectiveId())
						target = enemy
						break
					end
				end
			end
			if target then break end
		end
	end

	if target then
		self.room:setPlayerFlag(target, "xuanhuo_target")
		if use.to then
			use.to:append(target)
		end
	end
end

sgs.ai_skill_playerchosen.nosxuanhuo = function(self, targets)
	for _, player in sgs.qlist(targets) do
		if (player:getHandcardNum() <= 2 or player:getHp() < 2) and self:isFriend(player) 
			and not player:hasFlag("xuanhuo_target") and not self:needKongcheng(player) and not player:hasSkill("manjuan") then
			return player
		end
	end
end

sgs.nosfazheng_suit_value = 
{
	heart = 3.9
}

sgs.ai_chaofeng.nosfazheng = -3

sgs.ai_skill_choice.nosxuanfeng = function(self, choices)
	self:sort(self.enemies, "defense")
	local slash = sgs.Card_Parse(("slash[%s:%s]"):format(sgs.Card_NoSuit, 0))
	for _, enemy in ipairs(self.enemies) do
		if self.player:distanceTo(enemy)<=1 then
			return "damage"
		elseif not self:slashProhibit(slash ,enemy) then
			return "slash"
		end
	end
	return "nothing"
end

sgs.ai_skill_playerchosen.nosxuanfeng_damage = sgs.ai_skill_playerchosen.damage

sgs.ai_skill_playerchosen.nosxuanfeng_slash = sgs.ai_skill_playerchosen.zero_card_as_slash

sgs.ai_playerchosen_intention.nosxuanfeng_damage = 80
sgs.ai_playerchosen_intention.nosxuanfeng_slash = 80

sgs.ai_view_as.nosgongqi = function(card, player, card_place)
	local suit = card:getSuitString()
	local number = card:getNumberString()
	local card_id = card:getEffectiveId()
	if card:getTypeId() == sgs.Card_Equip then
		return ("slash:nosgongqi[%s:%s]=%d"):format(suit, number, card_id)
	end
end

local nosgongqi_skill={}
nosgongqi_skill.name="nosgongqi"
table.insert(sgs.ai_skills,nosgongqi_skill)
nosgongqi_skill.getTurnUseCard=function(self,inclusive)
	local cards = self.player:getCards("he")
	cards=sgs.QList2Table(cards)
	
	local equip_card
	
	self:sortByUseValue(cards,true)
	
	for _,card in ipairs(cards) do
		if card:getTypeId() == sgs.Card_Equip and ((self:getUseValue(card)<sgs.ai_use_value.Slash) or inclusive) then
			equip_card = card
			break
		end
	end

	if equip_card then		
		local suit = equip_card:getSuitString()
		local number = equip_card:getNumberString()
		local card_id = equip_card:getEffectiveId()
		local card_str = ("slash:nosgongqi[%s:%s]=%d"):format(suit, number, card_id)
		local slash = sgs.Card_Parse(card_str)
		
		assert(slash)
		
		return slash
	end
end

sgs.ai_skill_invoke.nosjiefan = function(self, data)
	local dying = data:toDying()
	local slashnum = 0
	local friend = dying.who
	local currentplayer = self.room:getCurrent()
	for _, slash in ipairs(self:getCards("Slash")) do
		if self:slashIsEffective(slash, currentplayer) then 
			slashnum = slashnum + 1  
		end 
	end
	return self:isFriend(friend) and not (self:isEnemy(currentplayer) and currentplayer:hasSkill("leiji") 
		and (currentplayer:getHandcardNum() > 2 or self:isEquip("EightDiagram", currentplayer))) and slashnum > 0
end

sgs.ai_skill_cardask["nosjiefan-slash"] = function(self, data, pattern, target)
	target = target or global_room:getCurrent()
	for _, slash in ipairs(self:getCards("Slash")) do
		if self:slashIsEffective(slash, target) then 
			return slash:toString()
		end 
	end
	return "."
end
