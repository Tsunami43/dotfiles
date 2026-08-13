vim.pack.add({ 'https://github.com/nvim-tree/nvim-web-devicons' })

-- nvim-web-devicons ships every glyph pre-coloured with the Nerd Fonts brand
-- palette: lua blue, json yellow, ts blue, folders blue again. None of that is
-- reachable from a colorscheme, so the icons in fzf and lualine are the one
-- part of the editor cendre never gets to touch — and against a warm ground
-- the brand blues read as spilled ink rather than as accent.
--
-- So the icons are re-cut here onto the same roles yazi's theme.toml and the
-- eza theme use, keyed off the extension or filename the plugin already
-- indexes by. The point is not that a .ts file is green; it is that "source"
-- looks like one thing wherever you meet it, in the editor and in the file
-- manager both.

local devicons = require('nvim-web-devicons')
devicons.setup({})

-- fg, cterm — cterm only matters where termguicolors is off, and is the
-- nearest 256-colour neighbour rather than an exact match.
local role = {
  code    = { '#99af6b', '107' }, -- sap    — source, scripts, anything you run
  doc     = { '#4e89a2', '67' },  -- frost  — prose, documents, symlinks
  data    = { '#fcba81', '215' }, -- brass  — config, structured data, assets
  media   = { '#9480ba', '103' }, -- iris   — audio, video, fonts
  archive = { '#d1766e', '174' }, -- cinder — archives, compiled objects, VCS
  crypto  = { '#f4a21c', '214' }, -- warn   — keys, signatures, checksums
  noise   = { '#73665b', '59' },  -- comment— lock files, caches, droppings
  plain   = { '#a09384', '144' }, -- fg_dim — no role of its own
}

local function split(s)
  local t = {}
  for word in s:gmatch('%S+') do t[word] = true end
  return t
end

local group = {
  code = split [[
    ada adb ads apl applescript asm astro awk azcli bash bat bazel bicep
    bicepparam blade.php bqn bzl c c++ cbl cc ccm cfc cfm cjs clj cljc cljd
    cljs cmake cob cobol coffee cp cpp cppm cpy cr cs csh cshtml cson css
    cts cu cuh cxx cxxm d d.ts dart dockerfile drl ebuild eex ejs el elm epp
    erb erl ex exs f# f90 feature fish fnl frag fs fsi fsscript fsx gd
    gemspec geom gleam glsl gnumakefile go godot gpr gql gradle graphql gv h
    haml hbs heex hh hpp hrl hs htm html http huff hurl hx hxx ino ipynb ixx
    java jl js jsx ksh kt kts leex less lhs liquid lua luau m makefile mint
    mjs mk ml mli mm mojo mts mustache nim nix nu odin php pl pm pp prisma
    pro ps1 psd1 psm1 pxd pxi py pyi pyw pyx qml query r rake razor rb res
    resi rs s sass sbt sc scad scala scm scss sh slim sml sol spec.js
    spec.jsx spec.ts spec.tsx sql stories.js stories.jsx stories.mjs
    stories.svelte stories.ts stories.tsx stories.vue styl sv svelte svh
    swift t tbc tcl templ test.js test.jsx test.ts test.tsx tf tfvars tmpl
    ts tsx twig typoscript v vala vert vh vhd vhdl vim vsh vue x xaml
    xcplayground xslt xul zig zsh
  ]],
  doc = split [[
    bib doc docx ebook epub fodp fodt ical icalendar ics ifb info license
    log man markdown md mdx mobi nfo norg odf odp odt org pdf po pot ppt
    pptx rmd rst rtf srt tex txt typ xcstrings
  ]],
  data = split [[
    3mf ai avif bak blend blp bmp brep cache cfg conda conf config.ru csproj
    csv db dconf desktop dockerignore dot dwg dxf edn env f3d fbx fcbak
    fcmacro fcmat fcparam fcscript fcstd fcstd1 fctb fctl fodg fods gcode
    gif glb gresource ico ifc ige iges igs image import ini jpeg jpg json
    json5 jsonc jxl kdenlive kdenlivetitle kicad_dru kicad_mod kicad_pcb
    kicad_prl kicad_pro kicad_sch kicad_sym kicad_wks kpp kra material mpp
    msf nswag obj odg ods ply png prisma.config properties psb psd qm qrc
    qss rasi rproj rss skp sldasm sldprt sln slnx slvs sqlite sqlite3 ste
    step stl stp strings sublime suo svg svgz terminal tif tiff tmux toml
    tres tscn tsconfig ui webmanifest webp webpack wrl wrz xcf xls xlsx xm
    xml yaml yml
  ]],
  media = split [[
    3gp aac aif aiff ape ass cast cue eot flac flc flf lff lrc m3u m3u8 m4a
    m4v mkv mov mp3 mp4 oga ogg ogv ogx opus otf pcm pls rm spx ssa sub ttf
    wav webm wma wmv woff woff2 wv wvc
  ]],
  archive = split [[
    7z a apk app bin bz bz2 bz3 crdownload diff dll download dump elc elf
    eln exe fdmdownload git gz hex img iso jar ko lck lib lock luac magnet
    mo o out part patch pck pyc pyd pyo rar rlib so tgz torrent txz vsix
    wasm xpi xz zip zst
  ]],
  crypto = split [[
    asc kbx kdb kdbx md5 pub sha1 sha224 sha256 sha384 sha512 sig signature
  ]],
}

-- Longest match wins by construction: `spec.ts` is looked up before `ts`.
local order = { 'code', 'doc', 'data', 'media', 'archive', 'crypto' }

local function by_extension(ext)
  ext = ext:lower()
  while true do
    for _, name in ipairs(order) do
      if group[name][ext] then return name end
    end
    local rest = ext:match('%.(.+)$')
    if not rest then return nil end
    ext = rest
  end
end

-- Files whose name, not suffix, says what they are.
local named = {}
local function name_all(names, r)
  for word in names:gmatch('%S+') do named[word] = r end
end
name_all([[ authors authors.txt code_of_conduct code_of_conduct.md copying
  copying.lesser license license.md readme readme.md rmd security security.md
  unlicense robots.txt py.typed checkhealth ]], 'doc')
name_all([[ .bash_profile .bashrc .gvimrc .justfile .nanorc .vimrc .xinitrc
  .xsession .zprofile .zshenv .zshrc _gvimrc _vimrc brewfile build build.gradle
  build.zig.zon cmakelists.txt containerfile dockerfile gemfile gnumakefile
  gradlew groovy jenkinsfile justfile makefile pkgbuild procfile rakefile
  settings.gradle vagrantfile workspace xmobarrc.hs xmonad.hs ]], 'code')
name_all([[ .git-blame-ignore-revs .gitattributes .gitconfig .gitignore
  .gitlab-ci.yml .gitmodules .mailmap commit_editmsg .npmignore .dockerignore
  .eslintignore .prettierignore ]], 'archive')
name_all([[ .ds_store bun.lock bun.lockb go.sum mix.lock node_modules
  package-lock.json pnpm-lock.yaml fp-info-cache ]], 'noise')

local function by_filename(name)
  name = name:lower()
  if named[name] then return named[name] end
  -- gulpfile.js, vite.config.ts, .prettierrc.yaml: the suffix says how the
  -- file is written, which is what the glyph should be reflecting.
  local rest = name:match('%.(.+)$')
  if rest then
    local r = by_extension(rest)
    if r then return r end
  end
  return 'data' -- a bare dotfile is nearly always config
end

local function recolour(icons, classify)
  for key, icon in pairs(icons) do
    if type(key) == 'string' and type(icon) == 'table' then
      local r = role[classify(key) or 'plain']
      icon.color, icon.cterm_color = r[1], r[2]
    end
  end
end

recolour(devicons.get_icons_by_extension(), by_extension)
recolour(devicons.get_icons_by_filename(), by_filename)
-- Distro and window-manager marks are logos rather than file kinds; they have
-- no role in the palette, so they sit at the quiet default too.
recolour(devicons.get_icons_by_operating_system(), function() return 'plain' end)
recolour(devicons.get_icons_by_desktop_environment(), function() return 'plain' end)
recolour(devicons.get_icons_by_window_manager(), function() return 'plain' end)

devicons.set_default_icon('', role.plain[1], role.plain[2])
devicons.set_up_highlights(true)
