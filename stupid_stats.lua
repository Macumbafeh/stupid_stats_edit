-- modern stupid stats strings (edit by Nonexistent - SAZEXX on git)
 
-- Как бы настройки
 
local fnt,fsize      = "Fonts\\Normal.ttf",12       -- шрифт и размер
local bg             = "interface\\tooltips\\UI-Tooltip-Background"     -- постоянная текстура 
local br             = "interface\\z_customize\\border.blp"             -- постоянный бордер
local off_x,off_y    = 5,GetScreenHeight()-fsize-6                      -- смещение строки от левого нижнего ула
local fcoeff         = 2.0                                              -- коэффициент пропорциональности шрифта         
 
local color =
   {
   std      = "|cff9966cc",      -- нормальный цвет (темнофиолетовый)
   bright   = "|cffff9933",      -- яркий цвет (золотой)
   dark     = "|cff003366",      -- темный цвет (синий)
   }
 
local _G = getfenv(0)
 
-- форматирование цвета и вида выводимой информации
 
local round = function(val,num) return (floor(val*10*num))/(10*num) end
local rgb2str  = function(r,g,b) return string.format("|cff%02x%02x%02x",r*255,g*255,b*255) end
 
color.normal = function(val) return color.std..val.."|r"end
 
color.binary = function(val,nil_val,val_val)
   if ((val==nil) or (val==0)) then return color.dark..nil_val.."|r" end
   return color.bright..val_val.."|r" 
end
 
--[[color.money = function(val)
   return string.format("|cffffd700%d|r.|cffbbbbdd%d|r.|cffeda55f%d|r",
             mod(val/10000,10000),mod(val/100,100),mod(val,100))
end--]]
 
color.class = function(val)
   val = strupper(val)
   if not _G["RAID_CLASS_COLORS"]  then return rgb2str(0.2,0.2,0.2) end
     return rgb2str(_G["RAID_CLASS_COLORS"][val].r, _G["RAID_CLASS_COLORS"][val].g, _G["RAID_CLASS_COLORS"][val].b)
end
 
color.level = function(val)
   local lcol =GetDifficultyColor(val) 
   if not lcol then return "|cffffffff" end
   return rgb2str(lcol.r,lcol.g,lcol.b)
end
 
color.gradient = function(val,bad,good)
   local percent,r,g
   if (good > bad) then percent = val/(good-bad)
   else percent = 1-val/(bad-good) end
   if (percent > 1) then percent = 1 end
   if (percent < 0) then percent = 0 end
   if(percent < 0.5) then r,g = 1,2*percent   else  r,g = (1-percent)*2,1 end
   return rgb2str(r,g,0)..val.."|r"
end
 
color.memory = function(val,bad,good)
   if val > 1024 then return color.gradient(round(val/1024,1),bad,good).." mb"
   else return color.gradient(round(val,1),bad*1024,good*1024).." kb" end
end
 
local line  = function(m1,m2) GameTooltip:AddDoubleLine(m1,m2,0.5,02,0.7,0.7,0.7,0.2) end
local space = function() GameTooltip:AddLine("\n") end  
 
-- основной фрейм (неинтерактивный)
 
local module = CreateFrame("Frame",nil,UIParent)
 
-- интерактивные фреймы (нужно добавлять нужные вам :)
 
--local friends  = CreateFrame("Frame",nil,module)
local guild    = CreateFrame("Frame",nil,module)
local perf     = CreateFrame("Frame",nil,module)
local stats    = CreateFrame("Frame",nil,module)
 
local guildtable,stattable = {},{},{}
 
-- функции получения нужной информации от игры
 
--local get_money   = function() return color.money(GetMoney()) end
--local get_time    = function() return color.normal(date("%H:%M")) end
--local get_fps     = function() return color.gradient(ceil(GetFramerate()),0,45) end
local get_mem     = function() return color.memory(collectgarbage("count"),40,10) end
--local get_lag     = function() return color.gradient((select(3,GetNetStats())),400,50) end    
--local get_mail    = function() return color.binary(HasNewMail(),"-mail","+mail") end
local get_guild   = "--"
--local get_friend  = "--" 
--local get_bags    = "--"  
--local get_loc     = "--"
--local get_q       = "--"
 
--[[local get_dura  = function()
   local cost,ndx,durability,d_val,d_max = GetRepairAllCost(),0,0,0,0
   for slot = 0,19 do
      d_val , d_max = GetInventoryItemDurability(slot)
      if(d_val) then durability = durability + d_val/d_max*100   ndx=ndx+1 end 
   end
   durability = floor(durability/ndx)
   local out_string = color.gradient(floor(durability),0,100).." % "
   if(cost > 0) then return out_string.."["..color.money(cost).."]" end
   return out_string
end--]]
 
local get_stats = function()                  --(специфично! себе пишите сами :)
   local _,str,_,_      = UnitStat("player", 1)
   local _,agi,_,_      = UnitStat("player", 2)
   local _,sta,_,_      = UnitStat("player", 3)
   local MH,OH          = UnitAttackSpeed("player")
   local AP,pos,neg     = UnitAttackPower("player") ; AP = AP+pos+neg
   local CRIT           = GetCritChance("player")
   stattable = {agi,sta,str,AP,CRIT,MH,OH}
   --return string.format("AGI : |cff996666%d|r AP : |cff999966%d|r CRIT : |cff996699%2.2f",agi,AP,CRIT).."%|r"
   return string.format("|cff996666*show stats*|r")
end   
 
-- вывод списка аддонов и занимаемой ими памяти
 
local show_addons = function()
   GameTooltip:SetOwner(perf,"ANCHOR_BOTTOMRIGHT")  
   local total,addons,all_mem = 0,{},collectgarbage("count")
    UpdateAddOnMemoryUsage()  
    for i=1,GetNumAddOns(), 1 do  
      if (GetAddOnMemoryUsage(i) > 0 ) then
        memory = GetAddOnMemoryUsage(i)  
        entry = {name=GetAddOnInfo(i),memory =memory}  
        table.insert(addons, entry) 
        total = total + memory
      end
    end  
    table.sort(addons,function(a,b) return a.memory > b.memory end)  
    line("ADDONS MEMORY USAGE :","\n")  
   i = 0  
    for _, entry in pairs(addons) do  
        line(entry.name,color.memory(entry.memory,2,0.1)) 
        i = i + 1  
        if i >= 50 then  break  end  
    end  
    space()
    line("Addons",color.memory(total,30,10))
    line("Blizz",color.memory(all_mem-total,20,5))
    line("Total",color.memory(all_mem,50,5))
    GameTooltip:Show()  
end
 
-- вывод информации о гильде 
 
local show_guild = function()
   GameTooltip:SetOwner(guild,"ANCHOR_BOTTOMRIGHT")  
   line("guild :",GetGuildInfo("player")) 
   line("motd  :",GetGuildRosterMOTD())
   space()
   for _, val in ipairs(guildtable) do
      line(string.format("%s%s|r  %s%s (%s)|r  in  %s",color.level(val[1]),val[1],color.class(val[3]),val[2],val[3],val[4]),val[5])
   end
   GameTooltip:Show()
end
 
-- вывод друзей
--[[local show_friends = function()
   GameTooltip:SetOwner(friends,"ANCHOR_BOTTOMRIGHT")  
   line("all friends:",GetNumFriends()) 
   space()
   for _, val in ipairs(friendtable) do
      line(string.format("%s%s|r  %s%s (%s)|r",color.level(val[1]),val[1],color.class(val[3]),val[2],val[3]),val[4])
   end
   GameTooltip:Show()
end--]]
 
-- вывод статов 
local show_stats = function()
   local SF = string.format
   local TS = tostring
  GameTooltip:SetOwner(guild,"ANCHOR_BOTTOMRIGHT")  
   line("|cffffff66ROGUE STATS|r")
   line("agility",TS(stattable[1]))
   line("stamina",TS(stattable[2]))
   line("strenght",TS(stattable[3]))
   line("AP",TS(stattable[4]))
   line("crit",SF("%2.2f",(stattable[5])).."%")
   line("MH speed",TS(stattable[6]))
   line("OH speed",TS(stattable[7]))
   GameTooltip:Show()
end
 
-- утилиты :)
 
local frame_setup = function(frame)
   frame.txt = frame:CreateFontString(nil,"OVERLAY") ;   frame.txt:SetPoint("CENTER",frame)
   frame.txt:SetFont(fnt,fsize,nil);      frame.txt:SetShadowOffset(1,-1)
   frame.txt:SetTextColor(0.5,0.5,0.7)
   frame:SetWidth(fsize+8);               frame:SetHeight(fsize+4)
   --frame:SetBackdrop({bgFile = bg, edgeFile = br,edgeSize = 8,insets = {left = 2, right = 2, top = 2, bottom = 2}})
   frame:SetFrameStrata("BACKGROUND") 
   frame:SetBackdropColor(0,0,0,0.9);      frame:SetBackdropBorderColor(1,1,1,1)
   frame:EnableMouse(true);                frame:SetMovable(true)               -- можно таскать мышкой  
   frame:SetScript("OnMouseDown", function(self) self:StartMoving() end)        -- двигаем 
   frame:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing() end)   -- не двигаем
   frame:Show()
end
 
local glue = function(pframe,frame,scale,anchor,anchor2,off_x,off_y)
   frame:SetScale(scale);
   frame:ClearAllPoints();
   frame:SetPoint(anchor,pframe,anchor2,off_x,off_y)  
end
 
-- onUpdate всех фреймов
 
module.on_update = function(self,elsp)  -- 
   self.update = self.update + elsp
   if(self.update > self.interval) then
         --local main_str    = string.format("D : %s  $ : %s  %s  Loc: %s  Q: %s B: %s ",get_dura(),get_money(),--[[get_mail(),--]]get_time(),get_loc,get_q,get_bags)
         --local perf_str    = string.format("%s fps  %s ms   %s",get_fps(),get_lag(),get_mem())
		 local perf_str    = string.format("   %s",get_mem())
         local guild_str   = "guild : "..get_guild
         --local friend_str  = "FR : "..get_friend
         local stats_str   = get_stats()
         --module.txt:SetText(main_str)    module:SetWidth(strlen(main_str) * fcoeff)
         perf.txt:SetText(perf_str)      perf:SetWidth(strlen(perf_str) * fcoeff)
         guild.txt:SetText(guild_str)    guild:SetWidth(strlen(guild_str) * fcoeff)
         --friends.txt:SetText(friend_str) friends:SetWidth(strlen(friend_str) * fcoeff)
         stats.txt:SetText(stats_str)    stats:SetWidth(strlen(stats_str) * fcoeff)
   self.update = 0;
   end
end
 
-- обработка сообщений
 
--[[module.BAG_UPDATE = function(self)   -- если изменилось что-то в сумках
   local all_slots,free_slots = 0,0
   for bag = 0,4 do
      local slots = GetContainerNumSlots(bag) 
      local free  = GetContainerNumFreeSlots(bag)
      all_slots   = all_slots + slots
      free_slots  = free_slots + free
   end
   get_bags = color.gradient(free_slots,0,all_slots).."/"..color.normal(all_slots)
end--]]
 
module.GUILD_ROSTER_UPDATE = function(self)  -- если изменилось что-то в гильдростере
   local total,online = 0,0
   guildtable = {}
   if IsInGuild() then
      total = GetNumGuildMembers(true)
      for ndx = 0, total do
         name,rnk,irnk,lvl,class,zone,note,onote,on,status = GetGuildRosterInfo(ndx)
         if(on and name) then 
            online = online + on 
            table.insert(guildtable,{lvl,name,class,zone,note})
          end
     end
   end
   get_guild = color.normal(online.."/"..total)
end
 
module.PLAYER_GUILD_UPDATE = function(self)  -- если игрок сменил гильдию
   self:GUILD_ROSTER_UPDATE()
end   
 
--[[module.UPDATE_PENDING_MAIL = function(self)  -- если пришла почта
   PlaySoundFile("interface\\z_customize\\mail_sound.mp3")
end--]]
 
--[[module.ZONE_CHANGED_NEW_AREA = function(self)
   get_loc = "|cffaa33aa"..GetRealZoneText().." ["..GetSubZoneText().."]|r"
end--]]
 
--[[module.FRIENDLIST_UPDATE = function(self)
   local total,online = GetNumFriends(),0
   friendtable = {}
   for ndx = 0,total do
      local name,lvl,class,zone,on,st,note = GetFriendInfo(ndx)
      if(on and name) then 
        table.insert(friendtable,{lvl,name,class,zone})
        online = online+1 end 
   end
   get_friend = color.normal(online.."/"..total)
end--]]
 
--[[module.QUEST_LOG_UPDATE = function(self)
   local ent, q = GetNumQuestLogEntries()
   get_q = color.gradient(q,ent,0).."/"..ent
end--]]
 
------- задаем расположение и поведение всех фреймов -----------------------------------------------------------
 
module.PLAYER_LOGIN = function(self)
   module.update    =  0.0
   module.interval  =  1.0  -- обновлять раз в секунду   frame_setup(perf)                                                             
   frame_setup(guild)                                                           
   --frame_setup(friends)                                                           
   frame_setup(module)                                                           
   frame_setup(stats)                                                           
   frame_setup(perf)                                                           
 
   GuildRoster()
 
   module:SetPoint("BOTTOMLEFT",UIParent,"BOTTOMLEFT",off_x,off_y)         -- местоположение
   glue(module,MiniMapTracking,0.7,"BOTTOMLEFT","BOTTOMRIGHT",-2,0)        -- приклеиваем трекинг
   glue(module,perf,1,"LEFT","RIGHT",20,0)                                 -- приклеиваем перформанс монитор 
   glue(perf,guild,1 ,"LEFT","RIGHT",0,0)                                  -- приклеиваем гильдию 
   --glue(guild,friends,1 ,"LEFT","RIGHT",0,0)                               -- приклеиваем друзей 
   glue(guild,stats,1 ,"LEFT","RIGHT",0,0)                               -- приклеиваем статсы 
 
   module:SetScript("OnUpdate",module.on_update)                             -- скрипты
   perf:SetScript("OnEnter", show_addons)
   perf:SetScript("OnLeave", function() GameTooltip:Hide() end)
   guild:SetScript("OnEnter", show_guild)
   guild:SetScript("OnLeave", function() GameTooltip:Hide() end)
  -- friends:SetScript("OnEnter", show_friends)
  -- friends:SetScript("OnLeave", function() GameTooltip:Hide() end)
   stats:SetScript("OnEnter", show_stats )
   stats:SetScript("OnLeave", function() GameTooltip:Hide() end)
 
   module:GUILD_ROSTER_UPDATE()
   --module:FRIENDLIST_UPDATE()
   --module:BAG_UPDATE()
   --module:ZONE_CHANGED_NEW_AREA()
   --module:QUEST_LOG_UPDATE()
end
 
-- регистрируем сообщения для фреймов
 
--module:RegisterEvent("BAG_UPDATE") 
module:RegisterEvent("GUILD_ROSTER_UPDATE")
--module:RegisterEvent("FRIENDLIST_UPDATE")
--module:RegisterEvent("UPDATE_PENDING_MAIL")
--module:RegisterEvent("ZONE_CHANGED_NEW_AREA")
--module:RegisterEvent("QUEST_LOG_UPDATE")
module:RegisterEvent("PLAYER_LOGIN")
 
module:SetScript("OnEvent",function(self,event,...) self[event](self,event,...) end)

function clearGarbage() -- new function
	UpdateAddOnMemoryUsage()
	local before = gcinfo()
	collectgarbage()
	UpdateAddOnMemoryUsage()
	local after = gcinfo()
	print("|c0000ddffCleaned:|r "..memFormat(before-after))
end

perf:SetScript("OnMouseDown", function()
	clearGarbage()
end)
