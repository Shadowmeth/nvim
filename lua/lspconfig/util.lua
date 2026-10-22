-- lspconfig/util.lua
--
-- Standalone copy of nvim-lspconfig's util module, so server configs that do
-- `require("lspconfig.util")` keep working without the plugin.
-- Neovim 0.11+ only. Functions that needed the rest of lspconfig were removed.

local M = { path = {} }

local function escape_wildcards(path)
  return path:gsub("([%[%]%?%*])", "\\%1")
end

function M.tbl_flatten(t)
  return vim.iter(t):flatten(math.huge):totable()
end

function M.search_ancestors(startpath, func)
  vim.validate("func", func, "function")
  if func(startpath) then
    return startpath
  end
  local guard = 100
  for path in vim.fs.parents(startpath) do
    guard = guard - 1
    if guard == 0 then
      return
    end
    if func(path) then
      return path
    end
  end
end

-- For zipfile: or tarfile: paths, returns the path to the archive.
function M.strip_archive_subpath(path)
  path = vim.fn.substitute(path, "zipfile://\\(.\\{-}\\)::[^\\\\].*$", "\\1", "")
  path = vim.fn.substitute(path, "tarfile:\\(.\\{-}\\)::.*$", "\\1", "")
  return path
end

--- Returns a function that finds the first parent folder containing any of
--- the given patterns (globs allowed).
function M.root_pattern(...)
  local patterns = M.tbl_flatten({ ... })
  return function(startpath)
    startpath = M.strip_archive_subpath(startpath)
    for _, pattern in ipairs(patterns) do
      local match = M.search_ancestors(startpath, function(path)
        local glob = table.concat({ escape_wildcards(path), pattern }, "/")
        for _, p in ipairs(vim.fn.glob(glob, true, true)) do
          if vim.uv.fs_stat(p) then
            return path
          end
        end
      end)

      if match ~= nil then
        return vim.uv.fs_realpath(match) or match
      end
    end
  end
end

--- Adds a file from `new_names` to `root_files` if it contains `field`.
function M.root_markers_with_field(root_files, new_names, field, fname, match_mode)
  local path = vim.fn.fnamemodify(fname, ":h")
  local found = vim.fs.find(new_names, { path = path, upward = true, type = "file" })
  local fields = type(field) == "string" and { field } or field
  local to_find = vim.deepcopy(fields)

  local matcher
  if (match_mode or "any") == "any" then
    matcher = function(line)
      return vim.iter(fields):any(function(s)
        return line:find(s)
      end)
    end
  else
    matcher = function(line)
      to_find = vim.iter(to_find)
        :filter(function(s)
          return not line:find(s)
        end)
        :totable()
      if #to_find == 0 then
        to_find = vim.deepcopy(fields)
        return true
      end
      return false
    end
  end

  for _, f in ipairs(found or {}) do
    local file = assert(io.open(f, "r"))
    for line in file:lines() do
      if matcher(line) then
        root_files[#root_files + 1] = vim.fs.basename(f)
        break
      end
    end
    file:close()
  end

  return root_files
end

function M.insert_package_json(root_files, field, fname)
  return M.root_markers_with_field(root_files, { "package.json", "package.json5" }, field, fname)
end

function M.get_typescript_server_path(root_dir)
  local roots = vim.fs.find("node_modules", {
    path = root_dir,
    upward = true,
    limit = math.huge,
  })
  for _, root in ipairs(roots) do
    local ts = root .. "/typescript"
    local stat = vim.uv.fs_stat(ts)
    if stat and stat.type == "directory" then
      return ts .. "/lib"
    end
  end
  return ""
end

-- Ancestor finders
local function find_ancestor(name, startpath)
  return vim.fs.dirname(vim.fs.find(name, { path = startpath, upward = true })[1])
end

function M.find_git_ancestor(startpath)
  return find_ancestor(".git", startpath)
end

function M.find_mercurial_ancestor(startpath)
  return find_ancestor(".hg", startpath)
end

function M.find_node_modules_ancestor(startpath)
  return find_ancestor("node_modules", startpath)
end

function M.find_package_json_ancestor(startpath)
  return find_ancestor("package.json", startpath)
end

-- Client helpers
function M.get_lsp_clients(filter)
  return vim.lsp.get_clients(filter)
end

function M.get_active_client_by_name(bufnr, servername)
  return vim.lsp.get_clients({ bufnr = bufnr, name = servername })[1]
end

function M.validate_bufnr(bufnr)
  vim.validate("bufnr", bufnr, "number")
  return bufnr == 0 and vim.api.nvim_get_current_buf() or bufnr
end

function M.bufname_valid(bufname)
  return bufname:match("^/") ~= nil
    or bufname:match("^[a-zA-Z]:") ~= nil
    or bufname:match("^zipfile://") ~= nil
    or bufname:match("^tarfile:") ~= nil
end

-- Hook helpers
function M.add_hook_before(func, new_fn)
  if not func then
    return new_fn
  end
  return function(...)
    new_fn(...)
    return func(...)
  end
end

function M.add_hook_after(func, new_fn)
  if not func then
    return new_fn
  end
  return function(...)
    func(...)
    return new_fn(...)
  end
end

-- Old path helpers (kept so older configs don't break)
function M.path.is_dir(filename)
  return vim.fn.isdirectory(filename) == 1
end

function M.path.is_file(path)
  return (vim.uv.fs_stat(path) or {}).type == "file"
end

function M.path.exists(filename)
  local stat = vim.uv.fs_stat(filename)
  return stat and stat.type or false
end

function M.path.join(...)
  return table.concat({ ... }, "/")
end

function M.path.is_descendant(root, path)
  if not path or not root then
    return false
  end
  return vim.fs.relpath(root, path) ~= nil
end

M.path.dirname = vim.fs.dirname
M.path.sanitize = vim.fs.normalize
M.path.iterate_parents = vim.fs.parents
M.path.path_separator = vim.fn.has("win32") == 1 and ";" or ":"

return M
