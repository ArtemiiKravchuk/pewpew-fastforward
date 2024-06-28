-- Convert color with hue to RGB colors
-- thanks so :з
-- https://stackoverflow.com/questions/68317097/how-to-properly-convert-hsl-colors-to-rgb-colors-in-lua
function hsv_to_rgb(h, s, l)
    h = h / 360
    s = s / 100
    l = l / 100

    local r, g, b;

    if s == 0 then
        r, g, b = l, l, l; -- achromatic
    else
        local function hue2rgb(p, q, t)
            if t < 0 then t = t + 1 end
            if t > 1 then t = t - 1 end
            if t < 1 / 6 then return p + (q - p) * 6 * t end
            if t < 1 / 2 then return q end
            if t < 2 / 3 then return p + (q - p) * (2 / 3 - t) * 6 end
            return p;
        end

        local q = l < 0.5 and l * (1 + s) or l + s - l * s;
        local p = 2 * l - q;
        r = hue2rgb(p, q, h + 1 / 3);
        g = hue2rgb(p, q, h);
        b = hue2rgb(p, q, h - 1 / 3);
    end

    if not a then a = 1 end
    return r * 255, g * 255, b * 255, a * 255
end


-- Insert several elements into table at once
-- thanks so :з
-- https://stackoverflow.com/questions/13214926/lua-insert-multiple-variables-into-a-table
-- [TODO: can be remade with new features of lua? for i=1, (...)]
function table_insert_all(table, ...)
  log.trace("hlpr", "Inserting multiple values into a table..")

  for i = 1, select('#',...) do
    table[#table+1] = select(i,...)
  end
end
