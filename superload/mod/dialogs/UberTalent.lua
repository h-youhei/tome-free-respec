local _M = loadPrevious(...)

local base_init = _M.init
function _M:init(actor, levelup_end_prodigies)
	self.unlearnedTalents = {}
	return base_init(self, actor, levelup_end_prodigies)
end

local base_use = _M.use
function _M:use(item)
	if self.actor:knowTalent(item.talent) then
		local t = self.actor:getTalentFromId(item.talent)
		if t.cant_steal or (t.on_learn and not t.on_unlearn) or (t.on_unlearn and not t.on_learn) then
			engine.ui.Dialog:simplePopup(util.getval(item.rawname, item), "You cannot unlearn this talent!")
			return
		end
		self.actor:unlearnTalent(item.talent, nil, nil, {no_unlearn=true})
		self.unlearnedTalents[item.talent] = true
		self.levelup_end_prodigies[item.talent] = true
		base_use(self, item)
	else
		base_use(self, item)
		if self.unlearnedTalents[item.talent] then
			self.actor:learnTalent(item.talent, true, nil, {no_unlearn=true})
			self.unlearnedTalents[item.talent] = false
			self.levelup_end_prodigies[item.talent] = false
		end
	end
end

function _M:getTalentDesc(item)
	if not item.talent then return end
		local text = tstring{}

	text:add({"color", "GOLD"}, {"font", "bold"}, util.getval(item.rawname, item), {"color", "LAST"}, {"font", "normal"})
	text:add(true, true)

	if item.talent then
		local t = self.actor:getTalentFromId(item.talent)
		if t.cant_steal or (t.on_learn and not t.on_unlearn) or (t.on_unlearn and not t.on_learn) then
			text:add({"color","YELLOW"}, _t"This talent can alter the world in a permanent way; as such, you can never unlearn it once known.", {"color","LAST"}, true, true)
		end
		local req = self.actor:getTalentReqDesc(item.talent)
		text:merge(req)
		if self.actor:knowTalent(t) then
			text:merge(self.actor:getTalentFullDescription(t))
		else
			text:merge(self.actor:getTalentFullDescription(t, 1))
		end
	end

	return text
end

return _M
