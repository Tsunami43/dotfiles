-- Custom spotter: shows file metadata with human-readable size and a
-- mimetype that wraps across rows instead of getting truncated.
local M = {}

local VALUE_WIDTH = 64

local function fmt_time(ts)
	if not ts or ts == 0 then
		return "-"
	end
	return os.date("%Y-%m-%d %H:%M:%S", math.floor(ts))
end

local function chunk(s, w)
	if not s or s == "" then
		return { "-" }
	end
	if #s <= w then
		return { s }
	end
	local out, i = {}, 1
	while i <= #s do
		table.insert(out, s:sub(i, i + w - 1))
		i = i + w
	end
	return out
end

local function split_path(path)
	local dir, name = path:match("^(.*)/([^/]+)/?$")
	if not dir or dir == "" then
		return "/", name or path
	end
	return dir, name
end

function M:spot(job)
	local file = job.file
	local cha = file.cha
	local path = tostring(file.url)
	local dir, name = split_path(path)

	local size_str
	if cha.is_dir then
		size_str = "<directory>"
	else
		local n = cha.len or 0
		size_str = string.format("%s  (%d bytes)", ya.readable_size(n), n)
	end

	local mime_lines = chunk(job.mime or "-", VALUE_WIDTH)

	local rows = {
		ui.Row({ "Name", name }),
		ui.Row({ "Location", dir }),
		ui.Row({ "Mimetype", mime_lines }):height(#mime_lines),
		ui.Row({ "Size", size_str }),
		ui.Row({ "Mode", cha:perm() or "-" }),
		ui.Row({ "Links", tostring(cha.nlink or 1) }),
		ui.Row({ "UID / GID", string.format("%s / %s", tostring(cha.uid or "-"), tostring(cha.gid or "-")) }),
		ui.Row({ "Created", fmt_time(cha.btime) }),
		ui.Row({ "Modified", fmt_time(cha.mtime) }),
		ui.Row({ "Accessed", fmt_time(cha.atime) }),
	}

	if file.link_to then
		table.insert(rows, ui.Row({ "Link to", tostring(file.link_to) }))
	end

	ya.spot_table(
		job,
		ui.Table(rows)
			:area(ui.Pos({ "center", w = 80, h = 22 }))
			:row(1)
			:col(1)
			:col_style(th.spot.tbl_col)
			:cell_style(th.spot.tbl_cell)
			:widths({ ui.Constraint.Length(12), ui.Constraint.Fill(1) })
	)
end

return M
