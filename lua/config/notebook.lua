-- Notebook cell operations for the jupytext markdown view.
--
-- jupytext turns an .ipynb into markdown where every code cell is a ```python
-- fenced block. Everything here works off those fences, located with treesitter
-- rather than by scanning for ``` so that fences inside strings or nested blocks
-- do not confuse it.
--
-- Execution counts are tracked here, not by molten: molten runs code
-- asynchronously and exposes no per-cell counter, so the count is assigned when
-- a cell is submitted — the same moment VSCode shows its [n].
local M = {}

local NS = vim.api.nvim_create_namespace 'notebook-exec-counts'

---------------------------------------------------------------------- cells --

--- All code cells in the buffer, in document order.
--- Returns a list of { srow, erow, lang } with 0-indexed, end-exclusive rows
--- covering the fence lines themselves.
function M.cells(buf)
  buf = buf or 0
  local ok, parser = pcall(vim.treesitter.get_parser, buf, 'markdown')
  if not ok or not parser then
    return {}
  end
  local tree = parser:parse()[1]
  if not tree then
    return {}
  end
  local query = vim.treesitter.query.parse('markdown', [[
    (fenced_code_block
      (info_string (language) @lang)?) @cell
  ]])

  local out, seen = {}, {}
  for id, node in query:iter_captures(tree:root(), buf, 0, -1) do
    if query.captures[id] == 'cell' then
      local srow, _, erow, _ = node:range()
      if not seen[srow] then
        seen[srow] = true
        local lang
        for child in node:iter_children() do
          if child:type() == 'info_string' then
            lang = vim.treesitter.get_node_text(child, buf):gsub('%s+', '')
          end
        end
        out[#out + 1] = { srow = srow, erow = erow, lang = lang or '' }
      end
    end
  end
  table.sort(out, function(a, b) return a.srow < b.srow end)
  return out
end

--- The cell containing the cursor, plus its index. nil if the cursor is in prose.
function M.current(buf)
  buf = buf or 0
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1
  for i, c in ipairs(M.cells(buf)) do
    if row >= c.srow and row < c.erow then
      return c, i
    end
  end
  return nil
end

------------------------------------------------------------- execution count --

local counts = setmetatable({}, { __mode = 'k' })  -- buf -> { [srow] = n }
local next_n = setmetatable({}, { __mode = 'k' })  -- buf -> next count to assign

--- Redraw the [n] markers in the sign column.
function M.render_counts(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_clear_namespace(buf, NS, 0, -1)
  local per_buf = counts[buf]
  if not per_buf then
    return
  end
  for _, c in ipairs(M.cells(buf)) do
    local n = per_buf[c.srow]
    if n then
      pcall(vim.api.nvim_buf_set_extmark, buf, NS, c.srow, 0, {
        sign_text = (n < 100) and string.format('%2d', n) or '**',
        sign_hl_group = 'NotebookExecCount',
      })
    end
  end
end

--- Record that the cell starting at `srow` has been submitted, and return its number.
local function bump(buf, srow)
  counts[buf] = counts[buf] or {}
  next_n[buf] = (next_n[buf] or 0) + 1
  counts[buf][srow] = next_n[buf]
  M.render_counts(buf)
  return next_n[buf]
end

function M.clear_counts(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  counts[buf], next_n[buf] = nil, nil
  vim.api.nvim_buf_clear_namespace(buf, NS, 0, -1)
end

----------------------------------------------------------------- run a cell --

--- Run the cell under the cursor through molten.
function M.run()
  local cell = M.current()
  if not cell then
    vim.notify('Not inside a code cell', vim.log.levels.WARN)
    return
  end
  -- skip the ``` fence lines: MoltenEvaluateRange takes 1-indexed, inclusive rows
  local first, last = cell.srow + 2, cell.erow - 1
  if first > last then
    vim.notify('Cell is empty', vim.log.levels.WARN)
    return
  end
  local buf = vim.api.nvim_get_current_buf()
  local ok = pcall(vim.cmd, string.format('%d,%dMoltenEvaluateRange', first, last))
  if not ok then
    vim.notify('No kernel — run <leader>ji first', vim.log.levels.WARN)
    return
  end
  bump(buf, cell.srow)
end

--- Run every code cell, top to bottom.
function M.run_all()
  local buf = vim.api.nvim_get_current_buf()
  for _, c in ipairs(M.cells(buf)) do
    local first, last = c.srow + 2, c.erow - 1
    if first <= last then
      if not pcall(vim.cmd, string.format('%d,%dMoltenEvaluateRange', first, last)) then
        vim.notify('No kernel — run <leader>ji first', vim.log.levels.WARN)
        return
      end
      bump(buf, c.srow)
    end
  end
end

-------------------------------------------------------------- edit the cells --

--- Insert a new cell. `lang` is a language for a code cell, or nil for markdown.
--- `above` puts it before the current cell instead of after.
function M.insert(lang, above)
  local buf = vim.api.nvim_get_current_buf()
  local cell = M.current(buf)
  local at
  if cell then
    at = above and cell.srow or cell.erow
  else
    at = vim.api.nvim_win_get_cursor(0)[1]   -- in prose: just below the cursor
  end

  local body = lang and { '```' .. lang, '', '```', '' } or { '', '' }
  vim.api.nvim_buf_set_lines(buf, at, at, false, body)
  vim.api.nvim_win_set_cursor(0, { at + (lang and 2 or 1), 0 })
  if lang then
    vim.cmd 'startinsert'
  end
  M.render_counts(buf)
end

--- Move the current cell one position up or down. dir is -1 or 1.
function M.move(dir)
  local buf = vim.api.nvim_get_current_buf()
  local cell, idx = M.current(buf)
  if not cell then
    vim.notify('Not inside a code cell', vim.log.levels.WARN)
    return
  end
  local all = M.cells(buf)
  local target = all[idx + dir]
  if not target then
    vim.notify('No cell to swap with', vim.log.levels.WARN)
    return
  end

  local a, b = cell, target
  if dir < 0 then a, b = target, cell end      -- a is always the earlier one
  local a_lines = vim.api.nvim_buf_get_lines(buf, a.srow, a.erow, false)
  local b_lines = vim.api.nvim_buf_get_lines(buf, b.srow, b.erow, false)
  local between = vim.api.nvim_buf_get_lines(buf, a.erow, b.srow, false)

  local merged = {}
  vim.list_extend(merged, b_lines)
  vim.list_extend(merged, between)
  vim.list_extend(merged, a_lines)
  vim.api.nvim_buf_set_lines(buf, a.srow, b.erow, false, merged)

  -- follow the cell the cursor was in
  local new_srow = (dir > 0) and (a.srow + #b_lines + #between) or a.srow
  vim.api.nvim_win_set_cursor(0, { new_srow + 1, 0 })
  M.clear_counts(buf)   -- counts are positional; moving invalidates them
end

--- Delete the cell under the cursor.
function M.delete()
  local buf = vim.api.nvim_get_current_buf()
  local cell = M.current(buf)
  if not cell then
    vim.notify('Not inside a code cell', vim.log.levels.WARN)
    return
  end
  vim.api.nvim_buf_set_lines(buf, cell.srow, cell.erow, false, {})
  M.render_counts(buf)
end

--------------------------------------------------------------------- kernel --

--- Pick a kernel from the ones Jupyter knows about.
function M.pick_kernel()
  local ok, raw = pcall(vim.fn.MoltenAvailableKernels)
  if not ok or type(raw) ~= 'table' or #raw == 0 then
    vim.notify('No Jupyter kernels found. Install one, e.g. python-ipykernel.', vim.log.levels.ERROR)
    return
  end
  vim.ui.select(raw, { prompt = 'Jupyter kernel' }, function(choice)
    if choice then
      vim.cmd('MoltenInit ' .. choice)
    end
  end)
end

--- Short kernel state for the statusline: "󱓞 python3" or nil when nothing is running.
function M.status()
  local ok, kernels = pcall(vim.fn.MoltenRunningKernels, true)
  if not ok or type(kernels) ~= 'table' or #kernels == 0 then
    return nil
  end
  return '󱓞 ' .. table.concat(kernels, ',')
end

----------------------------------------------------------------- per buffer --

--- Called for notebook buffers: hide line numbers, reserve the sign column for
--- the [n] markers, and keep the markers in step with edits.
function M.attach(buf)
  vim.api.nvim_set_hl(0, 'NotebookExecCount', { fg = '#7a1fff', bold = true })
  vim.wo.number = false
  vim.wo.relativenumber = false
  vim.wo.signcolumn = 'yes:1'
  vim.wo.conceallevel = 2
  vim.wo.foldcolumn = '0'

  vim.api.nvim_create_autocmd({ 'TextChanged', 'InsertLeave' }, {
    buffer = buf,
    group = vim.api.nvim_create_augroup('notebook-counts-' .. buf, { clear = true }),
    callback = function() M.render_counts(buf) end,
  })
end

return M
