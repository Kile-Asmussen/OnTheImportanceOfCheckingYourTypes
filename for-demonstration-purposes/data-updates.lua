-- The following code is equivalent in behavior to the existing code, but correct in all corner cases
-- It should be a drop-in replacement for the existing code in __base__/data-updates.lua
-- The good folk at Wube are free to use it.

local function generate_barrel_icons(fluid, base_icon, side_mask, top_mask)
  local base_icon_filename, base_icon_size

  if type(base_icon) == 'table' then -- IconData
    base_icon_filename = base_icon.icon
    base_icon_size = base_icon.icon_size or defines.default_icon_size
  elseif type(base_icon) == 'string' then -- FileName
    base_icon_filename = base_icon
    base_icon_size = defines.default_icon_size
  end
  
  return
  {
    {
      icon = base_icon_filename,
      icon_size = base_icon_size,
    },
    {
      icon = side_mask,
      icon_size = defines.default_icon_size,
      tint = util.get_color_with_alpha(fluid.base_color, side_alpha, true)
    },
    {
      icon = top_mask,
      icon_size = defines.default_icon_size, 
      tint = util.get_color_with_alpha(fluid.flow_color, top_hoop_alpha, true)
    }
  }
end