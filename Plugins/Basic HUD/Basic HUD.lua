-- Basic HUD 1.0, by treellama
-- based on M2 Default HUD by Hopper
-- from work by Bungie and the Aleph One developers

Triggers = {}
function Triggers.draw()
  if TexturePalette.draw() then return end
  
  if Player.motion_sensor.active then
    local sidelen = globals.motion_sensor_side_length
    
    local r = rects["motion sensor"]
    local fg = InterfaceColors["inventory text"]

    clip_motion_sensor(r.x, r.y, sidelen, sidelen)
    imgs["motion sensor virgin mount"]:draw(r.x, r.y)
    
    local comp36 = globals.network_compass_36
    local comp61 = globals.network_compass_61
    
    if Player.compass.nw then
      imgs["network compass nw"]:draw(r.x + comp36, r.y + comp36)
    end
    if Player.compass.ne then
      imgs["network compass ne"]:draw(r.x + comp61, r.y + comp36)
    end
    if Player.compass.se then
      imgs["network compass se"]:draw(r.x + comp61, r.y + comp61)
    end
    if Player.compass.sw then
      imgs["network compass sw"]:draw(r.x + comp36, r.y + comp61)
    end

    for i = 1,#Player.motion_sensor.blips do
      local blip = Player.motion_sensor.blips[i - 1]
      local img = imgs["motion sensor " .. blip.type.mnemonic .. " " .. blip.intensity]
      
      local mult = (blip.distance/globals.motion_sensor_range) * (globals.motion_sensor_scale)
      local rad = math.rad(blip.direction)
      local xoff = r.x + (sidelen / 2) + (math.cos(rad) * mult)
      local yoff = r.y + (sidelen / 2) + (math.sin(rad) * mult)
      
      img:draw(xoff - (img.width / 2), yoff - (img.height / 2))
    end
    unclip_motion_sensor()
    
  end

  if true then
    local x = rects["inventory"].x
    local y = rects["inventory"].y
    local w = Screen.width - x
    local h = Screen.height - y
    local fg = InterfaceColors["inventory text"]
    local bg = InterfaceColors["inventory background"]

    Screen.fill_rect(x - adj(2), y - adj(2), w + adj(2), h, bg)
    Screen.fill_rect(x - adj(2), y, w, h, bg)
  end
  
  -- inventory
  if true then
    local r = rects["inventory"]
    local f = int_fonts["interface"]
    local rowh = f.line_height
    local sec = Player.inventory_sections.current
    
    -- header
    Screen.fill_rect(r.x, r.y, r.width, rowh, InterfaceColors["inventory header background"]);
    draw_text_trunc(f, sec.name, r.x + globals.text_inset, r.y, r.width - globals.text_inset, InterfaceColors["inventory text"])
    
    -- content
    Screen.fill_rect(r.x, r.y + rowh, r.width, r.height - rowh, InterfaceColors["inventory background"])
    if sec.type == InventorySections["network statistics"] then
      network_stats_draw()
    else
      inventory_items_draw()
    end
  end
  
  -- weapons
  if true then
    local r = rects["weapon display"]
    Screen.fill_rect(r.x, r.y, r.width, r.height, InterfaceColors["inventory background"])
    
    local wep = Player.weapons.desired
    if wep then
      -- weapon shapes
      local shpinfo = wep_shapes[wep.type]
      if shpinfo.unusable then
        weapon_shape_draw(shpinfo.single)
        if Player.items[wep.type.mnemonic].count > 1 then
          weapon_shape_draw(shpinfo.multiple)
        else
          weapon_shape_draw(shpinfo.unusable)
        end
      elseif shpinfo.multiple then
        if Player.items[wep.type.mnemonic].count > 1 then
          weapon_shape_draw(shpinfo.multiple)
        else
          weapon_shape_draw(shpinfo.single)
        end
      else
        weapon_shape_draw(shpinfo.single)
      end
      
      -- name
      weapon_name_draw(wep.name, wep_nrects[wep.type], true)
      
      -- ammo
      if wep.primary then
        if wep.primary.bullet_display then
          weapon_bullet_draw(wep.primary)
        elseif wep.primary.energy_display then
          weapon_energy_draw(wep.primary)
        end
      end
      if wep.secondary then
        if wep.secondary.bullet_display then
          weapon_bullet_draw(wep.secondary)
        elseif wep.secondary.energy_display then
          weapon_energy_draw(wep.secondary)
        end
      end
    end
  end

  -- frame health and O2
  if false then
     local r = rects["shield"]
     local s = rects["oxygen"]
     Screen.fill_rect(r.x - 1, r.y - 1, r.width + 2, 1, InterfaceColors["inventory text"])
     Screen.fill_rect(r.x + r.width + 1, r.y - 1, 1, r.height + s.height + 4, InterfaceColors["inventory text"])
  end

  -- health
  if true then
     local r = rects["shield"]
     local nrg = globals.player_maximum_suit_energy
     if Player.energy > 2*nrg then
        draw_bar(r, (Player.energy - 2*nrg) / nrg,
                 imgs["triple energy bar right"],
                 imgs["triple energy bar"],
                 imgs["double energy bar"])
     elseif Player.energy > nrg then
        draw_bar(r, (Player.energy - nrg) / nrg,
                 imgs["double energy bar right"],
                 imgs["double energy bar"],
                 imgs["energy bar"])
     else
        draw_bar(r, math.max(Player.energy, 0) / nrg,
                 imgs["energy bar right"],
                 imgs["energy bar"],
                 imgs["empty energy bar"])
     end
  end

  -- O2
  if true then
     local r = rects["oxygen"]
     -- oxygen
     draw_bar(r, Player.oxygen / globals.player_maximum_suit_oxygen,
              imgs["oxygen bar right"],
              imgs["oxygen bar"],
              imgs["empty oxygen bar"])
  end
  
  -- player name
  if #Game.players > 1 then
    local r = rects["player name"]

    draw_text_center(int_fonts["player name"],
                     Player.name,
                     r.x + 1, r.y + 1, r.width,
                     { 0, 0, 0, 1})
    draw_text_center(int_fonts["player name"],
      Player.name,
      r.x, r.y, r.width,
      InterfaceColors[Player.color.mnemonic .. " player"])
  end
  
end

function Triggers.resize()
  if TexturePalette.resize() then return end

  Screen.clip_rect.width = Screen.width
  Screen.clip_rect.x = 0
  Screen.clip_rect.height = Screen.height
  Screen.clip_rect.y = 0

  Screen.map_rect.width = Screen.width
  Screen.map_rect.x = 0
  Screen.map_rect.height = Screen.height
  Screen.map_rect.y = 0
  
--  local min_aspect_ratio = 1.6
--  local max_aspect_ratio = 2.4
--  local h = math.min(Screen.height, Screen.width / min_aspect_ratio)
  --  local w = math.min(Screen.width, h*max_aspect_ratio)
  local h = Screen.height
  local w = Screen.width
  Screen.world_rect.width = w
  Screen.world_rect.x = (Screen.width - w)/2
  Screen.world_rect.height = h
  Screen.world_rect.y = (Screen.height - h)/2

  if Screen.map_overlay_active then
    Screen.map_rect.x = Screen.world_rect.x
    Screen.map_rect.y = Screen.world_rect.y
    Screen.map_rect.width = Screen.world_rect.width
    Screen.map_rect.height = Screen.world_rect.height
  end
  
  local ww = Screen.width
  local wh = Screen.height
  
  -- calculate HUD area
  hud_rect = {}
  local hudsize = Screen.hud_size_preference
  hud_rect.width = 640
  if hudsize == SizePreferences["double"] then
    if ww >= 2560 then
      hud_rect.width = 1280
    end
  elseif hudsize == SizePreferences["largest"] then
     hud_rect.width = ww / 2
  end
  
  hud_rect.height = hud_rect.width / 4
--  hud_rect.x = math.floor((ww - hud_rect.width) / 2)
  --  hud_rect.y = math.floor(wh - hud_rect.height)

  hud_rect.scale = hud_rect.width / 640

  hud_rect.x = ww - hud_rect.width
  hud_rect.y = wh - hud_rect.height

--  hud_rect.x = hud_rect.x + hud_rect.width - adj(InterfaceRects["inventory"].width) - adj(InterfaceRects["inventory"].x) - adj(InterfaceRects["weapon display"].width)

  local iw_right = math.max(InterfaceRects["inventory"].x + InterfaceRects["inventory"].width, InterfaceRects["weapon display"].x + InterfaceRects["weapon display"].width)
  local iw_bottom = math.max(InterfaceRects["inventory"].y - 320 + InterfaceRects["inventory"].height, InterfaceRects["weapon display"].y - 320 + InterfaceRects["weapon display"].height)

  hud_rect.x = ww - adj(iw_right)
  hud_rect.y = wh - adj(iw_bottom)

  local sidelen = adj(123)

  -- calculate terminal area
  local termsize = Screen.term_size_preference
  if termsize == SizePreferences["normal"] then
    Screen.term_rect.width = 640
  elseif termsize == SizePreferences["double"] then
     if (wh - sidelen * 2) >= 640 and ww >= 1280 then
      Screen.term_rect.width = 1280
    end
  elseif termsize == SizePreferences["largest"] then
     Screen.term_rect.width = math.min(ww, math.max(640, 2 * (wh - sidelen * 2)))
  end
  
  Screen.term_rect.height = Screen.term_rect.width / 2
  Screen.term_rect.x = math.floor((ww - Screen.term_rect.width) / 2)
  Screen.term_rect.y = math.floor((wh - Screen.term_rect.height) / 2)
  
  -- recalculate screen fonts
  for k, v in pairs(int_fonts) do
    v.scale = hud_rect.scale
  end
  
  -- recalculate interface rectangles
  rects = {}
  for r in InterfaceRects() do
    rects[r.mnemonic] = adj_rect(r)
  end

  -- scale images
  for k, v in pairs(imgs) do
    v:rescale(adj(v.unscaled_width), adj(v.unscaled_height))
  end
  
  -- scale weapon shapes
  for k, v in pairs(wep_shapes) do
    for kk, vv in pairs(v) do
      if vv.shp then
        vv.shp:rescale(adj(vv.shp.unscaled_width), adj(vv.shp.unscaled_height))
      end
      vv.x = adj_x(vv.orig_x)
      vv.y = adj_y(vv.orig_y)
    end
  end
  
  -- scale bullet shapes
  for k, v in pairs(ammo_shapes) do
    v:rescale(adj(v.unscaled_width), adj(v.unscaled_height))
  end
 
  -- recalculate weapon name rects
  wep_nrects = {}
  for wt in WeaponTypes() do
    wep_nrects[wt] = adj_rect(Player.weapons[wt].name_rect)
  end
  
  -- recalculate globals
  globals = {
    message_area_x_offset = adj(-9),
    message_area_y_offset = adj(-5),
    text_inset = adj(2),
    name_offset = adj(23),
    top_of_bar_width = adj(8),
    motion_sensor_side_length = adj(123),
    motion_sensor_scale = adj(64),
    network_compass_36 = adj(36),
    network_compass_61 = adj(61),
    player_maximum_suit_energy = 150,
    player_maximum_suit_oxygen = 6*30*60,
    motion_sensor_range = 8
  }

  -- move the motion sensor and health to the bottom left
  rects["motion sensor"].x = Screen.world_rect.x
  rects["motion sensor"].y = Screen.world_rect.y + Screen.world_rect.height - globals.motion_sensor_side_length

  rects["shield"].x = Screen.world_rect.x + globals.motion_sensor_side_length + 5
  rects["shield"].y = Screen.world_rect.y + Screen.world_rect.height - rects["shield"].height - rects["oxygen"].height - 3

  rects["oxygen"].x = Screen.world_rect.x + globals.motion_sensor_side_length + 5
  rects["oxygen"].y = Screen.world_rect.y + Screen.world_rect.height - rects["oxygen"].height - 1

  Screen.text_margins.bottom = globals.motion_sensor_side_length + 1;

end

function Triggers.init()
  if not (WeaponTypes["fist"] == nil) then WeaponTypes["fist"].mnemonic = "knife" end

  int_fonts = {}
  for ftype in InterfaceFonts() do
    int_fonts[ftype.mnemonic] = Fonts.new{ interface = ftype }
  end

  imgs = {}
  imgs["motion sensor mask"] = Images.new { path = "resources/motion_sensor_mask.png" }
  imgs["interface panel"] = Images.new{ resource = 1700 }
  
  for idx, name in ipairs({
    "empty energy bar",
    "energy bar",
    "energy bar right",
    "double energy bar",
    "double energy bar right",
    "triple energy bar",
    "triple energy bar right",
    "empty oxygen bar",
    "oxygen bar",
    "oxygen bar right",
    "motion sensor mount",
    "motion sensor virgin mount",
    "motion sensor alien 0",
    "motion sensor alien 1",
    "motion sensor alien 2",
    "motion sensor alien 3",
    "motion sensor alien 4",
    "motion sensor alien 5",
    "motion sensor friend 0",
    "motion sensor friend 1",
    "motion sensor friend 2",
    "motion sensor friend 3",
    "motion sensor friend 4",
    "motion sensor friend 5",
    "motion sensor hostile player 0",
    "motion sensor hostile player 1",
    "motion sensor hostile player 2",
    "motion sensor hostile player 3",
    "motion sensor hostile player 4",
    "motion sensor hostile player 5",
    "network panel" }) do
    imgs[name] = Shapes.new{ collection = 0, texture_index = idx - 1, type = TextureTypes["interface"] }
  end
  
  for idx, name in ipairs({
    "network compass nw",
    "network compass ne",
    "network compass sw",
    "network compass se" }) do
    imgs[name] = Shapes.new{ collection = 0, texture_index = idx + 50, type = TextureTypes["interface"] }
  end
  
  wep_shapes = {}
  ammo_shapes = {}
  for wt in WeaponTypes() do
    local wep = Player.weapons[wt]
    wep_shapes[wt] = {}
    if wep.shape then
      local s = wep.shape
      wep_shapes[wt].single = {
        shp = Shapes.new{ collection = 0, type = TextureTypes["interface"],
                  texture_index = s.texture_index },
        orig_x = s.x,
        orig_y = s.y }
    end
    if wep.multiple_shape then
      local s = wep.multiple_shape
      wep_shapes[wt].multiple = {
        shp = Shapes.new{ collection = 0, type = TextureTypes["interface"],
                  texture_index = s.texture_index },
        orig_x = s.x,
        orig_y = s.y }
    end
    if wep.multiple_unusable_shape then
      local s = wep.multiple_unusable_shape
      wep_shapes[wt].unusable = {
        shp = Shapes.new{ collection = 0, type = TextureTypes["interface"],
                  texture_index = s.texture_index },
        orig_x = s.x,
        orig_y = s.y }
    end

    if wep.primary and wep.primary.bullet_display then
      local disp = wep.primary.bullet_display
      if not ammo_shapes[disp.texture_index] then
        ammo_shapes[disp.texture_index] = Shapes.new{ collection = 0, type = TextureTypes["interface"], texture_index = disp.texture_index }
      end
      if not ammo_shapes[disp.empty_texture_index] then
        ammo_shapes[disp.empty_texture_index] = Shapes.new{ collection = 0, type = TextureTypes["interface"], texture_index = disp.empty_texture_index }
      end
    end
    if wep.secondary and wep.secondary.bullet_display then
      local disp = wep.secondary.bullet_display
      if disp.texture_index then
        if not ammo_shapes[disp.texture_index] then
          ammo_shapes[disp.texture_index] = Shapes.new{ collection = 0, type = TextureTypes["interface"], texture_index = disp.texture_index }
        end
      end
      if disp.empty_texture_index then
        if not ammo_shapes[disp.empty_texture_index] then
          ammo_shapes[disp.empty_texture_index] = Shapes.new{ collection = 0, type = TextureTypes["interface"], texture_index = disp.empty_texture_index }
        end
      end
    end
  end
     
  Triggers.resize()
end

function adj(len)
  return len * hud_rect.scale
end
function adj_x(x)
  return hud_rect.x + adj(x)
end
function adj_y(y)
  return hud_rect.y + adj(y - 320)
end
function adj_rect(r)
  return { x = adj_x(r.x),
           y = adj_y(r.y),
           width = adj(r.width),
           height = adj(r.height) }
end

function draw_bar(r, frac, cap, full, empty)
  empty.crop_rect.width = empty.width
  empty:draw(r.x, r.y)
  
  local width = r.width * frac
  local capw = globals.top_of_bar_width
  
  if width > 2 * capw then
    cap.crop_rect.width = cap.width
    cap.crop_rect.x = 0
    cap:draw(r.x + width - capw, r.y)
    
    full.crop_rect.width = width - capw
    full:draw(r.x, r.y)
  else
    cap.crop_rect.width = width/2
    cap.crop_rect.x = capw - width/2
    cap:draw(r.x + width/2, r.y)
    
    full.crop_rect.width = width/2
    full:draw(r.x, r.y)
  end
end

function trunc_text(font, text, w)
  local tw, th = font:measure_text(text)
  local trunc = false
  while tw > w do
    text = string.sub(text, 1, -2)
    tw, th = font:measure_text(text .. string.char(201))
    trunc = true
  end
  if trunc then text = text .. string.char(201) end
  return text, tw
end

function draw_text_trunc(font, text, x, y, w, color)
  local tt, tw = trunc_text(font, text, w)
  font:draw_text(tt, x, y, color)
end

function draw_text_center(font, text, x, y, w, color)
  local tt, tw = trunc_text(font, text, w)
  font:draw_text(tt, x + sfloor((w - tw)/2), y, color)
end

function draw_text_right(font, text, x, y, color)
  local tw, th = font:measure_text(text)
  font:draw_text(text, x - tw, y, color)
end

function clip(x, y, w, h)
  local rect = Screen.clip_rect
  rect.x = x
  rect.y = y
  rect.width = w
  rect.height = h
end

function cliprect(r)
  local rect = Screen.clip_rect
  rect.x = r.x
  rect.y = r.y
  rect.width = r.width
  rect.height = r.height
end

function unclip()
  local rect = Screen.clip_rect
  rect.x = 0
  rect.y = 0
  rect.width = Screen.width
  rect.height = Screen.height
end

function clip_motion_sensor(x, y, w, h)
  if Screen.renderer == "software" then
    clip(x, y, w, h)
  else
    unclip()
    Screen.clear_mask()
    Screen.masking_mode = MaskingModes["drawing"]
    imgs["motion sensor mask"]:draw(x, y)    
    Screen.masking_mode = MaskingModes["enabled"]
  end
end

function unclip_motion_sensor()
  if Screen.renderer == "software" then
    unclip()
  else
    Screen.masking_mode = MaskingModes["disabled"]
  end
end

function sfloor(num)
  return num - (num % hud_rect.scale)
end

function format_time(ticks)
  local secs = math.floor(ticks / 30)
  return string.format("%d:%02d", math.floor(secs / 60), secs % 60)
end

function player_ranking_text(gametype, ranking)
  if     gametype == "kill monsters" or
         gametype == "capture the flag" or
         gametype == "rugby" or
         gametype == "most points" then
    return string.format("%d", ranking)
  elseif gametype == "least points" then
    return string.format("%d", -ranking)
  elseif gametype == "cooperative play" then
    return string.format("%d%%", ranking)
  elseif gametype == "most time" or
         gametype == "least time" or
         gametype == "king of the hill" or
         gametype == "kill the man with the ball" or
         gametype == "defense" or
         gametype == "tag" then
    return format_time(math.abs(ranking))
  end
  return nil
end

function sorted_players()
  local sort_tbl = {}
  for i = 1,#Game.players do
    table.insert(sort_tbl, { rank = Game.players[i - 1].ranking, idx = i - 1 })
  end
  local sortfunc = function(a, b)
                     if a.rank ~= b.rank then return a.rank > b.rank end
                     return a.idx < b.idx
                   end
  table.sort(sort_tbl, sortfunc)
  
  local splayers = {}
  for i = 1,#sort_tbl do
    table.insert(splayers, Game.players[sort_tbl[i].idx])
  end
  return splayers
end

function inventory_item_draw(item, y)
  local r = rects["inventory"]
  local clr = InterfaceColors["inventory text"]
  if not item.valid then clr = InterfaceColors["invalid weapon"] end
  
  local iname = item.plural
  if item.count == 1 then iname = item.singular end
  draw_text_trunc(
    int_fonts["interface"],
    iname,
    r.x + globals.name_offset + globals.text_inset,
    y,
    r.width - globals.name_offset - globals.text_inset,
    clr)
  
  draw_text_trunc(
    int_fonts["interface item count"],
    string.format("%3d", item.count),
    r.x + globals.text_inset,
    y,
    globals.name_offset + globals.text_inset,
    clr)
end

function inventory_items_draw()
  local r = rects["inventory"]
  local rowh = int_fonts["interface"].line_height
  local maxrows = r.height / rowh
  local currow = 1
  local section = Player.inventory_sections.current.type
  
  for itype in ItemTypes() do
    if currow < maxrows and itype ~= ItemTypes["knife"] then
      local item = Player.items[itype]
      if item.inventory_section == section and item.count > 0 then
        inventory_item_draw(item, r.y + (currow * rowh))
        currow = currow + 1
      end
    end
  end
end

function inventory_right_draw(text, currow)
  local r = rects["inventory"]
  local f = int_fonts["interface"]
  draw_text_right(f, text, r.x + r.width - globals.text_inset, r.y + (currow * f.line_height), InterfaceColors["inventory text"])
end

function inventory_right_draw(text, currow)
  local r = rects["inventory"]
  local f = int_fonts["interface"]
  draw_text_right(f, text, r.x + r.width - globals.text_inset, r.y + (currow * f.line_height), InterfaceColors["inventory text"])
end

function network_stats_draw()
  local r = { xl = rects["inventory"].x + globals.text_inset,
              xr = rects["inventory"].x + rects["inventory"].width - globals.text_inset,
              y = rects["inventory"].y,
              width = rects["inventory"].width - (2*globals.text_inset) }
  local f = int_fonts["interface"]
  local rowh = f.line_height
  
  -- time/score display in header
  if Game.time_remaining and Game.time_remaining <= 30*60*999 then
    draw_text_right(f, format_time(Game.time_remaining),
                    r.xr, r.y, InterfaceColors["inventory text"])
    
  elseif Game.kill_limit then
    local lim = Game.kill_limit
    local gt = Game.type.mnemonic
    if gt == "kill monsters" or
       gt == "cooperative play" or
       gt == "king of the hill" or
       gt == "kill the man with the ball" or
       gt == "tag" then
      local leastleft = nil
      for p = 1,#Game.players do
        local thisleft = lim - Game.players[p - 1].kills
        if (not leastleft) or thisleft < leastleft then
          leastleft = thisleft
        end
      end
      
      draw_text_right(f, string.format("%d", leastleft),
                      r.xr, r.y, InterfaceColors["inventory text"])
    end
  end
  
  -- player listing
  for idx, p in ipairs(sorted_players()) do
    r.y = r.y + rowh
    local clr = InterfaceColors[p.color.mnemonic .. " player"]
    
    draw_text_trunc(f, p.name, r.xl, r.y, r.width, clr)
    
    draw_text_right(f, player_ranking_text(Game.type, p.ranking),
                    r.xr, r.y, clr)
  end
end

function weapon_name_draw(txt, nr, vertical)
  local f = int_fonts["weapon name"]
  local fh = f.line_height
  local w, h = f:measure_text(txt)
  
  local draw_single = function(singleline, vert)
      local y = nr.y
      if vert then
        if fh > nr.height then
          y = nr.y - fh + adj(2)
        else
          local off = nr.height - fh
          y = nr.y + nr.height - fh - sfloor(off/2) - adj(1)
        end
      else
        if fh > nr.height then
          y = nr.y + nr.height - fh
        else
          y = nr.y
        end
      end
      draw_text_center(f, singleline, nr.x, y, nr.width, InterfaceColors["inventory text"])
    end
  
  -- will we fit on one line?
  if w <= nr.width then
    draw_single(txt, vertical)
    return
  end
  
  -- no more words?
  local spos, epos = string.find(txt, " ")
  if not spos then
    draw_single(txt, vertical)
    return
  end
  
  -- if we get here, we need to split
  local lineend = spos
  w, h = f:measure_text(string.sub(txt, 1, spos - 1))
  while w < nr.width do
    spos, epos = string.find(txt, " ", lineend + 1)
    if not spos then
      w = nr.width
    else
      w, h = f:measure_text(string.sub(txt, 1, spos - 1))
      if w < nr.width then lineend = spos end
    end
  end
  
  draw_single(string.sub(txt, 1, lineend - 1), false)
  weapon_name_draw(string.sub(txt, lineend + 1, -1), { x = nr.x, width = nr.width, y = nr.y + f.line_height, height = nr.height - f.line_height }, false)
end

function weapon_shape_draw(shpinfo)
  if shpinfo and shpinfo.shp then
    shpinfo.shp:draw(shpinfo.x, shpinfo.y)
  end
end

function weapon_bullet_draw(trigger)
  local disp = trigger.bullet_display
  local rounds = trigger.rounds
  if rounds < 0 then return end
  local max = disp.across * disp.down
  if rounds > max then rounds = max end
  local dr = adj_rect(disp)
  
  local full = ammo_shapes[disp.texture_index]
  if not full then return end
  local empty = ammo_shapes[disp.empty_texture_index]
  if not empty then return end
  
  local row = 0
  full.crop_rect.x = 0
  full.crop_rect.width = full.width
  while row < math.floor(rounds / disp.across) do
    full:draw(dr.x, dr.y)
    dr.y = dr.y + dr.height
    row = row + 1
  end
  
  local partial = rounds % disp.across
  if partial > 0 then
    full.crop_rect.width = partial * dr.width
    empty.crop_rect.width = (disp.across - partial) * dr.width
    if disp.right_to_left then
      full.crop_rect.x = 0
      full:draw(dr.x, dr.y)
      empty.crop_rect.x = full.crop_rect.width
      empty:draw(dr.x + empty.crop_rect.x, dr.y)
    else
      empty.crop_rect.x = 0
      empty:draw(dr.x, dr.y)
      full.crop_rect.x = empty.crop_rect.width
      full:draw(dr.x + full.crop_rect.x, dr.y)
    end
    dr.y = dr.y + dr.height
  end
  
  row = 0
  empty.crop_rect.x = 0
  empty.crop_rect.width = empty.width
  while row < math.floor((max - rounds) / disp.across) do
    empty:draw(dr.x, dr.y)
    dr.y = dr.y + dr.height
    row = row + 1
  end
end

function weapon_energy_draw(trigger)
  local disp = trigger.energy_display
  local rounds = trigger.rounds
  if rounds < 0 then return end
  if rounds > disp.maximum then rounds = disp.maximum end
  
  local dr = adj_rect(disp)
  Screen.fill_rect(dr.x, dr.y, dr.width, dr.height, disp.color)
  dr.x = dr.x + adj(1)
  dr.y = dr.y + adj(1)
  dr.width = dr.width - adj(2)
  dr.height = dr.height - adj(2)
  
  local fill_height = sfloor((rounds * dr.height) / disp.maximum)
  Screen.fill_rect(dr.x, dr.y, dr.width, dr.height - fill_height, disp.empty_color)  
end


-- BEGIN texture palette utility
--
-- Use: in Triggers.draw: "if TexturePalette.draw() then return end"
--    in Triggers.resize: "if TexturePalette.resize() then return end"

TexturePalette = {}
TexturePalette.active = false

function TexturePalette.check_active()
  local old_active = TexturePalette.active
  local new_active = false
  if Player.texture_palette.size > 0 then new_active = true end
  TexturePalette.active = new_active
  
  if old_active and not new_active then
    Screen.crosshairs.lua_hud = TexturePalette.saved_crosshairs_lua_hud
    Triggers.resize()
  elseif new_active and not old_active then
    TexturePalette.palette_cache = {}
    TexturePalette.saved_crosshairs_lua_hud = Screen.crosshairs.lua_hud
    Screen.crosshairs.lua_hud = false
    TexturePalette.resize()
  end
  return TexturePalette.active
end

function TexturePalette.get_shape(slot)
  local key = string.format("%d %d", slot.collection, slot.texture_index)
  local shp = TexturePalette.palette_cache[key]
  if not shp then
    shp = Shapes.new{collection = slot.collection, texture_index = slot.texture_index, type = slot.type}
    TexturePalette.palette_cache[key] = shp
  end
  return shp
end

function TexturePalette.draw_shape(slot, x, y, size)
  local shp = TexturePalette.get_shape(slot)
  if not shp then return end
  if shp.width > shp.height then
    shp:rescale(size, shp.unscaled_height * size / shp.unscaled_width)
    shp:draw(x, y + (size - shp.height)/2)
  else
    shp:rescale(shp.unscaled_width * size / shp.unscaled_height, size)
    shp:draw(x + (size - shp.width)/2, y)
  end
end

function TexturePalette.draw(hr)
  if not TexturePalette.check_active() then return false end
  
  local hr = TexturePalette.hud_rect
  local tcount = Player.texture_palette.size
  local size
  if     tcount <=   5 then size = 128
  elseif tcount <=  16 then size =  80
  elseif tcount <=  36 then size =  53
  elseif tcount <=  64 then size =  40
  elseif tcount <= 100 then size =  32
  elseif tcount <= 144 then size =  26
  else                      size =  20
  end
  size = size * hr.scale
  
  local rows = math.floor(hr.height/size)
  local cols = math.floor(hr.width/size)
  local x_offset = hr.x + (hr.width - cols * size)/2
  local y_offset = hr.y + (hr.height - rows * size)/2
  
  for i = 0,tcount - 1 do
    TexturePalette.draw_shape(
      Player.texture_palette.slots[i],
      (i % cols) * size + x_offset + hr.scale/2,
      math.floor(i / cols) * size + y_offset + hr.scale/2,
      size - hr.scale)
  end
  
  if Player.texture_palette.highlight then
    local i = Player.texture_palette.highlight
    Screen.frame_rect(
      (i % cols) * size + x_offset,
      math.floor(i / cols) * size + y_offset,
      size, size,
      InterfaceColors["inventory text"],
      hr.scale)
  end
  
  return true
end

function TexturePalette.resize()
  if not TexturePalette.check_active() then return false end
  
  local ww = Screen.width
  local wh = Screen.height
  
  -- calculate HUD area
  TexturePalette.hud_rect = {}
  local hudsize = Screen.hud_size_preference
  TexturePalette.hud_rect.width = 640
  if hudsize == SizePreferences["double"] then
    if wh >= 960 and ww >= 1280 then
      TexturePalette.hud_rect.width = 1280
    end
  elseif hudsize == SizePreferences["largest"] then
    TexturePalette.hud_rect.width = math.min(ww, math.max(640, (4 * wh) / 3));
  end
  
  TexturePalette.hud_rect.height = TexturePalette.hud_rect.width / 4
  TexturePalette.hud_rect.x = math.floor((ww - TexturePalette.hud_rect.width) / 2)
  TexturePalette.hud_rect.y = math.floor(wh - TexturePalette.hud_rect.height)
  
  TexturePalette.hud_rect.scale = TexturePalette.hud_rect.width / 640

  -- remove HUD height from rest of calculations
  wh = TexturePalette.hud_rect.y
  
  -- calculate terminal area
  local termsize = Screen.term_size_preference
  Screen.term_rect.width = 640
  if termsize == SizePreferences["double"] then
    if wh >= 640 and ww >= 1280 then
      Screen.term_rect.width = 1280
    end
  elseif termsize == SizePreferences["largest"] then
    Screen.term_rect.width = math.min(ww, math.max(640, 2 * wh))
  end
  
  Screen.term_rect.height = Screen.term_rect.width / 2
  Screen.term_rect.x = math.floor((ww - Screen.term_rect.width) / 2)
  Screen.term_rect.y = math.floor((wh - Screen.term_rect.height) / 2)
  
  -- calculate world-view area
  Screen.world_rect.width = math.min(ww, math.max(640, 2 * wh))
  Screen.world_rect.height = Screen.world_rect.width / 2
  Screen.world_rect.x = math.floor((ww - Screen.world_rect.width) / 2)
  Screen.world_rect.y = math.floor((wh - Screen.world_rect.height) / 2)

  -- calculate map area
  if Screen.map_overlay_active then
    -- overlay just matches world-view
    Screen.map_rect.width = Screen.world_rect.width
    Screen.map_rect.height = Screen.world_rect.height
    Screen.map_rect.x = Screen.world_rect.x
    Screen.map_rect.y = Screen.world_rect.y
  else
    Screen.map_rect.width = ww
    Screen.map_rect.height = wh
    Screen.map_rect.x = 0
    Screen.map_rect.y = 0
  end
  
  Screen.clip_rect.width = Screen.width
  Screen.clip_rect.height = Screen.height
  Screen.clip_rect.x = 0
  Screen.clip_rect.y = 0

  return true
end

-- END texture palette utility
