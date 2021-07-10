long_name = "Free Respec"
short_name = "free-respec" -- Determines the name of your addons file.
for_module = "tome"
version = {1,7,2}
addon_version = {1,1,4}
weight = 100 -- lower the value, sooner the addon will load relative to other addons.
author = {'hukumitu.youhei@gmail.com'}
homepage = {'https://hkmtyh.com'}
description = [[Allow trial and error for character building without restarting new game while minimizing inbalance.

You can respec stats, talents, categories and prodigies freely at any time.
You cannot respec stats below initial value.
You cannot respec categories known at start.
You cannot respec categories learnt from event without category point.
You cannot respec prodigies that cannot be learned with Writhing Ring of the Hunter.

Based on Full Respecialization. Fix the bug for prodigies learning introduced v1.7.

Weight: 100

Superload:
- mod/dialogs/LevelupDialog.lua:incStat() to respec stats.
- mod/dialogs/LevelupDialog.lua:isUnlearnable() to respec talents.
- mod/dialogs/LevelupDialog.lua:learnType() to respec categories.
- mod/dialogs/LevelupDialog.lua:init() to recognize respeccing prodigies.
- mod/dialogs/UberTalent.lua:init(), use() to respec prodigies.
- mod/dialogs/UberTalent.lua:getTalentDesc() to show which prodigies cannot respec.]]


tags = {'talents', 'categories', 'stats', 'respec', 'prodigies'}

overload = false
superload = true
data = false
hooks = false
