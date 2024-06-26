local helpers = require"entities/helpers/general"
local ch = require"helpers/color_helpers"

module = {}


-- Create a specific label
function module.create_label(x, y, text, colors, scale, angle)
  -- local alpha = 255

  local label = new_entity(x, y)
  entity_set_mesh_scale(label, scale)
  entity_add_mesh_angle(label, angle, 0fx, 0fx, 1fx)

  local time = 0
  function label_update_callback()
    time = time + 1

    local color = helpers.get_color_state(time)
    if color ~= nil then
      local color = colors[color]
      local text = ch.color_to_string(color) .. text
      entity_set_string(label, text)
    end
  end

  entity_set_update_callback(label, label_update_callback)

  return label
end


function module.create_bold_label(x, y, text, colors, scale, angle, width)

  for i=1, width do
    local label = module.create_label(x+i, y+i, text, colors, scale, angle)
  end

end


return module