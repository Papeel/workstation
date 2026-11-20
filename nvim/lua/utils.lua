local M = {}

-- Convierte snake_case o kebab-case a CamelCase
local function to_camel_case(str)
    local result = str:gsub("[-_](%w)", function(c)
        return c:upper()
    end)
    -- Capitaliza la primera letra
    result = result:gsub("^%l", string.upper)
    return result
end

-- Obtiene el nombre base del fichero actual (sin path ni extensión) y lo convierte a CamelCase
function M.filename_to_camelcase()
    -- nombre completo del fichero
    local file = vim.fn.expand("%:t:r") -- %:t=r -> solo nombre, sin extensión
    return to_camel_case(file)
end

return M
