local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

local utils = require("utils")

return {
    s("classfile", {
        -- class NombreClase:
        t("class "),
        f(function() return utils.filename_to_camelcase() end, {}),
        t(":"),
        t({"", "    "}), -- salto de línea e indentación
        i(0),           -- cursor dentro de la clase
    }),
}

