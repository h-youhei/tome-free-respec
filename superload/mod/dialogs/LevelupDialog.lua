local _M = loadPrevious(...)

local base_init = _M.init
function _M:init(actor, on_finish, on_birth)
	base_init(self, actor, on_finish, on_birth)
	self.key:addBinds{
		EXIT = function()
			local changed = #self.actor.last_learnt_talents.class ~= #self.actor_dup.last_learnt_talents.class or #self.actor.last_learnt_talents.generic ~= #self.actor_dup.last_learnt_talents.generic
			for i = 1, #self.actor.last_learnt_talents.class do if self.actor.last_learnt_talents.class[i] ~= self.actor_dup.last_learnt_talents.class[i] then changed = true end end
			for i = 1, #self.actor.last_learnt_talents.generic do if self.actor.last_learnt_talents.generic[i] ~= self.actor_dup.last_learnt_talents.generic[i] then changed = true end end
	-- original logic just check unused_prodigies to recognize changes
	-- but when you unlearn a prodigy, then learn another prodigy
	-- unused_prodigies is same value but prodigies are changed
			if self.on_finish_prodigies then
				for tid, ok in pairs(self.on_finish_prodigies) do
					if ok then
						changed = true
						break
					end
				end
			end
			if self.actor.unused_stats~=self.actor_dup.unused_stats or self.actor.unused_talents_types~=self.actor_dup.unused_talents_types or
			self.actor.unused_talents~=self.actor_dup.unused_talents or self.actor.unused_generics~=self.actor_dup.unused_generics or self.actor.unused_prodigies~=self.actor_dup.unused_prodigies or changed then
				self:yesnocancelPopup(_t"Finish",_t"Do you accept changes?", function(yes, cancel)
					if cancel then
						return nil
					else
						if yes then ok = self:finish() else ok = true self:cancel() end
					end
					if ok then
						game:unregisterDialog(self)
						self.actor_dup = {}
						if self.on_finish then self.on_finish() end
					end
				end)
			else
				game:unregisterDialog(self)
				self.actor_dup = {}
				if self.on_finish then self.on_finish() end
			end
		end,
	}
end

local base_incStat = _M.incStat
function _M:incStat(sid, v)
	if not self.actor.initial_stats then
		self.actor.initial_stats = {}
		for k, v in pairs(self.actor.stats) do
			self.actor.initial_stats[k] = v
		end
	end
	if v == 1 then
		base_incStat(self, sid, v)
		return
	else
		if self.actor:getStat(sid, nil, nil, true) <= self.actor.initial_stats[sid] then
			self:subtleMessage(_t"Impossible", _t"You cannot take out more points!", subtleMessageErrorColor)
			return
		end
	end
	self.actor:incStat(sid, v)
	self.actor.unused_stats = self.actor.unused_stats - v
	self.stats_increased[sid] = (self.stats_increased[sid] or 0) + v
	self:updateTooltip()
end

function _M:isUnlearnable(t, limit)
	-- Dont let them unlearn talents granted by items
	if self.actor.item_talent_levels_learnt and self.actor.item_talent_levels_learnt[t.id] then
		if self.actor:getTalentLevelRaw(t) <= self.actor.item_talent_levels_learnt[t.id] then return nil end
	end

	if config.settings.cheat then return 9999 end

	if t.no_unlearn_last and self.actor_dup:getTalentLevelRaw(t_id) >= self.actor:getTalentLevelRaw(t_id) then return nil end

	return 1
end

local base_learnType = _M.learnType
function _M:learnType(tt, v)
	-- categories manually spent points
	self.actor.talent_types_learned = self.actor.talent_types_learned or {}
	-- learn
	if v then
		base_learnType(self, tt, v)
		if self.talent_types_learned[tt][1] then self.actor.talent_types_learned[tt] = true end
	-- unlearn
	else
		self.talent_types_learned[tt] = self.talent_types_learned[tt] or {}
		if not self.actor:knowTalentType(tt) then
			self:subtleMessage(_t"Impossible", _t"You do not know this category!", subtleMessageErrorColor)
			return
		end

		if (self.actor.__increased_talent_types[tt] or 0) > 0 then
			self.actor.__increased_talent_types[tt] = (self.actor.__increased_talent_types[tt] or 0) - 1
			self.actor:setTalentTypeMastery(tt, self.actor:getTalentTypeMastery(tt) - 0.2)
			self.actor.unused_talents_types = self.actor.unused_talents_types + 1
			self.new_talents_changed = true
			self.talent_types_learned[tt][2] = nil
		else
			-- to forbid unlearning initial categories and categories get from events
			if self.actor.talent_types_learned[tt] then
				self.actor:unlearnTalentType(tt)
				local ok, dep_miss = self:checkDeps(nil, true)
				if ok then
					self.actor.unused_talents_types = self.actor.unused_talents_types + 1
					self.new_talents_changed = true
					self.talent_types_learned[tt][1] = nil
					self.actor.talent_types_learned[tt] = nil
				else
					self:simpleLongPopup(_t"Impossible", _t"You cannot unlearn this category because of: "..dep_miss, game.w * 0.4)
					self.actor:learnTalentType(tt)
					return
				end
			else
				self:subtleMessage(_t"Impossible", _t"You cannot unlearn this category!", subtleMessageWarningColor)
				return
			end
		end
		self:triggerHook{"PlayerLevelup:subTalentType", actor=self.actor, tt=tt}
	end
	self:updateTooltip()
end

return _M
