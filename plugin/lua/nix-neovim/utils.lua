local M = {}

-- https://stackoverflow.com/questions/11201262/how-to-read-data-from-a-file-in-lua
M.from_json =  function(path)
    local file = io.open(path, "rb") -- r read mode and b binary mode
    if not file then return nil end
    local content = file:read "*a" -- *a or *all reads the whole file
    file:close()

    local ok, res = pcall(vim.fn.json_decode, content)
    if ok then
      return res
    else
      -- TODO: Give error message in a good way
    end
end

return M
