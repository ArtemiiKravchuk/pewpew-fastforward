local performance = require"misc/performance"
local bullets = require"entities/enemies/polygon/bullets/logic"
local helpers = require"entities/helpers"
local ch = require"helpers/color_helpers"

require"entities/enemies/polygon/config"

local module = {}

local entities = {}

-- Some entity globals
local speed = 2fx
local radius = 30fx
local default_health = 5

-- [NOTE: cant have maximum alpha value,
--  its increased for effect, when hit by bullet]
local colors = {0x009a6590, 0xa700fd90,
  0xe0340090, 0x80808090}

local explosion_color = colors[1]

-- Declaring scheme for entity table
local i_time = 1
local i_angle = 2
local i_dx = 3
local i_dy = 4
local i_health = 5
local i_highlight = 6
local i_meshi = 7


-- Function to explode the polygon, spawn bullets, etc..
function module.destroy_polygon(polygon_id, color)
  entity_start_exploding(polygon_id, 15)
  performance.increase_player_score(5)

  local x, y = entity_get_pos(polygon_id)
  create_explosion(x, y, color, 2fx, 50)

  local a = FX_TAU / TOTAL_BULLETS
  for i=1, TOTAL_BULLETS do
    local bullet1 = bullets.spawn(x, y, a * i - GROUP_SPREAD)
    local bullet2 = bullets.spawn(x, y, a * i + GROUP_SPREAD)
    entity_set_mesh_angle(bullet1, a * i - GROUP_SPREAD, 0fx, 0fx, 1fx)
    entity_set_mesh_angle(bullet2, a * i + GROUP_SPREAD, 0fx, 0fx, 1fx)
  end
end


-- Function to call every tick on entity
function update_callback()
  local e = entities[id]
  if not e then
    return
  end
  e[i_time] = e[i_time] + 1
  e[i_highlight] = e[i_highlight] - 1

  entity_change_pos(id, e[i_dx] * SPEED, e[i_dy] * SPEED)

  if e[i_meshi] >= ANIMATION_TIME*60 then
    e[i_meshi] = 0
  end

  entity_set_mesh(id, "entities/enemies/polygon/mesh", e[i_meshi], e[i_mesh_index]+1)
  e[i_meshi] = e[i_mesh_index] + 2

  local color_state = helpers.get_color_state(e[i_time])
  if color_state then
    color = colors[color_state]
    explosion_color = color
    if highlight > 0 then
      entity_set_mesh_color(id, ch.make_color_with_alpha(color, 255))
    else
      entity_set_mesh_color(id, color)
    end
  end

end


-- Fixing interpolation at first 2 ticks
-- has to be after update_callback due to local visibility
local function initial_interpolation_fix(id)
  local e = entities[id]
  if not e then
    return
  end
  e[i_time] = e[i_time] + 1
  if e[i_time] == 2 then
    entity_set_update_callback(id, update_callback)
    entity_set_mesh(id, "entities/enemies/polygon/mesh")
  end
end


-- Set wall collision callback function for the entity
function wall_collision(entity_id, wall_normal_x, wall_normal_y)
  local e = entities[entity_id]
  local dot_product_move = ((wall_normal_x * e[i_dx]) + (wall_normal_y * e[i_dy])) * 2fx
  e[i_dx] = e[i_dx] - wall_normal_x * dot_product_move
  e[i_dy] = e[i_dy] - wall_normal_y * dot_product_move
  e[i_angle] = fx_atan2(e[i_dy], e[i_dx])
  entity_set_mesh_angle(id, e[i_angle], 0fx, 0fx, 1fx)
end


-- Set player collision callback function for the entity
function player_collision(entity_id, player_id, ship_id)
  local e = entities[entity_id]

  if e then
    local health = e[i_health]

    if health > 3 then
      damage_player_ship(ship_id, 3)
    else
      damage_player_ship(ship_id, health)
    end
    module.destroy_polygon(entity_id, explosion_color)

    entities[entity_id] = nil
    performance.increase_player_score(3)
  end
end


-- Set weapon collision callback function for the entity
function weapon_collision(entity_id, player_index, weapon)
  local e = entities[entity_id]

  if e then
    local health = e[i_health]

    if health > 0 then
      if weapon == weapon_type.bullet then
        e[i_health] = health - 1  -- [TODO: assigning to health, reference to array?]
        e[i_highlight] = 5
        if health <= 0 then
          module.destroy_polygon(entity_id, explosion_color)
        end
      end
    end
  end

  return true
end


-- Spawn entity, add update callback
function module.spawn(x, y, angle)

  local id = new_entity(x, y)
  entity_start_spawning(id, 2)
  entity_set_radius(id, radius)

  local dy, dx = fx_sincos(angle)
  entity_set_mesh_angle(id, angle, 0fx, 0fx, 1fx)
  
  entities[id] = {0, angle, dx, dy, default_health, 0, 0}

  entity_set_update_callback(id, initial_interpolation_fix)
  entity_set_wall_collision(id, true, wall_collision)
  entity_set_player_collision(id, player_collision)
  entity_set_weapon_collision(id, weapon_collision)

  return id 
end


return module