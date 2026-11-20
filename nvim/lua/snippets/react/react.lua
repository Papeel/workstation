local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

local utils = require("utils")

local component_name = function()
  return utils.filename_to_camelcase()
end

return {
  -- Componente funcional con el nombre del fichero
  s({ trig = "rfc", priority = 2000 }, {
    t("export function "),
    f(component_name, {}),
    t({ "() {", "  return (", "    <div>" }),
    i(0),
    t({ "</div>", "  );", "}" }),
  }),
  -- Igual, con export default
  s({ trig = "rfce", priority = 2000 }, {
    t("function "),
    f(component_name, {}),
    t({ "() {", "  return (", "    <div>" }),
    i(0),
    t({ "</div>", "  );", "}", "", "export default " }),
    f(component_name, {}),
    t(";"),
  }),
  -- useState
  s({ trig = "us", priority = 2000 }, {
    t("const ["),
    i(1, "state"),
    t(", set"),
    f(function(args)
      return (args[1][1]:gsub("^%l", string.upper))
    end, { 1 }),
    t("] = useState("),
    i(2),
    t(");"),
  }),
}
