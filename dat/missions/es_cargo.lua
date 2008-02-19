lang = naev.lang()
if lang == "es" then
   -- not translated atm
else -- default english
   misn_desc = "The Empire needs to ship %d tons of %s to %s in the %s system."
   misn_reward = "%d credits"
   title = {}
   title[1] = "ES: Ship to %s"
   title[2] = "ES: Delivery to %s"
   full_title = "Ship is full"
   full_msg = "Your ship is too full.  You need to make room for %d more tons if you want to be able to accept the mission."
   accept_title = "Mission Accepted"
   accept_msg = "The Empire workers load the %d tons of %s onto your ship."
   toomany_title = "Too many missions"
   toomany_msg = "You have too many active missions."
   finish_title = "Succesful Delivery"
   finish_msg = "The Empire workers unload the %s at the docks."
   miss_title = "Cargo Missing"
   miss_msg = "You are missing the %d tons of %s!."
end

      

-- Create the mission
function create()

   -- target destination
   local i = 0
   repeat
      planet = space.getPlanet( misn.factions() )
      i = i + 1
   until planet ~= space.landName() or i > 10
   -- infinite loop protection
   if i > 10 then
      misn.finish(false)
   end
   system = space.getSystem( planet )
   misn_dist = space.jumpDist(system)

   -- mission generics
   misn_type = "Cargo"
   i = rnd.int(1)
   misn.setTitle( string.format(title[i+1], planet) )

   -- more mission specifics
   carg_mass = rnd.int( 10, 30 )
   i = rnd.int(12)
   if i < 5 then
      carg_type = "Food"
   elseif i < 8 then
      carg_type = "Ore"
   elseif i < 10 then
      carg_type = "Industrial Goods"
   elseif i < 12 then
      carg_type = "Luxury Goods"
   else
      carg_type = "Medicine"
   end

   misn.setDesc( string.format( misn_desc, carg_mass, carg_type, planet, system ) )
   reward = misn_dist * carg_mass * (500+rnd.int(250)) +
         carg_mass * (250+rnd.int(150)) +
         rnd.int(2500)
   misn.setReward( string.format( misn_reward, reward ) )
end

-- Mission is accepted
function accept()
   if player.freeCargo() < carg_mass then
      tk.msg( full_title, string.format( full_msg, carg_mass-player.freeCargo() ))
   elseif misn.accept() then -- able to accept the mission, hooks BREAK after accepting
      carg_id = player.addCargo( carg_type, carg_mass )
      tk.msg( accept_title, string.format( accept_msg, carg_mass, carg_type ))
      hook.land( "land" ) -- only hook after accepting
   else
      tk.msg( toomany_title, toomany_msg )
   end
end

-- Land hook
function land()
   if space.landName() == planet then
      if player.rmCargo( carg_id ) then
         player.pay( reward )
         tk.msg( finish_title, string.format( finish_msg, carg_type ))

         -- increase empire shipping mission counter
         n = var.peek("es_misn")
         if n ~= nil then
            var.push("es_misn", n+1)
         else
            var.push("es_misn", 1)
         end

         misn.finish(true)
      else
         tk.msg( miss_title, string.format( miss_msg, carg_mass, carg_type ))
      end
   end
end

