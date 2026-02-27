local TitleFrame = LibNUI.TitleFrame
local TableFrame = LibNUI.TableFrame

LibNUITest = {}
local Test = LibNUITest

local windows = {}

-- -----------------------------------------------------------------------
-- Helpers
-- -----------------------------------------------------------------------

local function window(title, width, height, anchorX, anchorY)
  local f = TitleFrame:new{
    name  = "LibNUITest_" .. title:gsub("%s+", ""),
    title = title,
  }
  f:Size(width, height)
  f:SetPoint("CENTER", UIParent, "CENTER", anchorX, anchorY)
  return f
end

-- -----------------------------------------------------------------------
-- Window 1 — Basic columns
--   Tests: colNames, plain string data, default alternating colBackdrop
-- -----------------------------------------------------------------------

local function makeBasicColumns(anchorX, anchorY)
  local f = window("Basic Columns", 360, 220, anchorX, anchorY)

  local t = TableFrame:new{
    parent      = f,
    colNames    = {"Name", "Role", "Level", "Zone"},
    cellWidth   = 80,
    cellHeight  = 20,
    headerHeight = 24,
    data = {
      {"Thrall",       "Shaman",  "60", "Orgrimmar"},
      {"Jaina",        "Mage",    "60", "Stormwind"},
      {"Sylvanas",     "Hunter",  "60", "Undercity"},
      {"Anduin",       "Priest",  "60", "Stormwind"},
      {"Illidan",      "DH",      "70", "Outland"},
    },
  }
  t:SetPoint("TOPLEFT", f._widget, "TOPLEFT", 8, -38)
  t:onLoad()
  return f
end

-- -----------------------------------------------------------------------
-- Window 2 — Row + column headers
--   Tests: colInfo (width, justifyH, color), rowInfo, rowHeaderFont
-- -----------------------------------------------------------------------

local function makeRowAndColHeaders(anchorX, anchorY)
  local f = window("Row + Column Headers", 400, 200, anchorX, anchorY)

  local t = TableFrame:new{
    parent      = f,
    colInfo     = {
      {name = "DPS",    width = 100, justifyH = "RIGHT",  color = {1, 0.4, 0.4, 1}},
      {name = "HPS",    width = 100, justifyH = "RIGHT",  color = {0.4, 1, 0.4, 1}},
      {name = "Deaths", width = 80,  justifyH = "CENTER", color = {1, 1, 1,   1}},
    },
    rowInfo     = {
      {name = "Tank"},
      {name = "Healer"},
      {name = "DPS 1"},
      {name = "DPS 2"},
    },
    cellWidth   = 100,
    cellHeight  = 20,
    headerHeight = 22,
    headerWidth  = 70,
    data = {
      {"1,200",  "0",     "1"},
      {"800",    "42,000","0"},
      {"95,000", "0",     "2"},
      {"87,000", "0",     "0"},
    },
  }
  t:SetPoint("TOPLEFT", f._widget, "TOPLEFT", 8, -38)
  t:onLoad()
  return f
end

-- -----------------------------------------------------------------------
-- Window 3 — Autosize
--   Tests: autosize=true, padding, colInfo per-column widths ignored in
--   favour of content width, colBackdrop override
-- -----------------------------------------------------------------------

local function makeAutosize(anchorX, anchorY)
  local f = window("Autosize Columns", 20, 20, anchorX, anchorY) -- will resize

  local t = TableFrame:new{
    parent      = f,
    colInfo     = {
      {name = "Spell"},
      {name = "Casts"},
      {name = "Avg Hit"},
      {name = "Max Hit"},
    },
    colBackdrop  = {color = {0.1, 0.1, 0.3, 0.8}},
    cellHeight   = 20,
    headerHeight = 22,
    padding      = 6,
    autosize     = true,
    data = {
      {"Fireball",                "342", "18,440", "54,210"},
      {"Pyroblast",               "87",  "52,100", "131,400"},
      {"Fire Blast",              "210", "9,800",  "24,500"},
      {"Combustion (buff uptime)","4",   "—",      "—"},
    },
  }
  t:SetPoint("TOPLEFT", f._widget, "TOPLEFT", 8, -38)
  t:onLoad()
  -- shrink-wrap the window to the table after autosize runs
  f:Size(t:Width() + 16, t:Height() + 46)
  return f
end

-- -----------------------------------------------------------------------
-- Window 4 — Dynamic addRow / addCol
--   Tests: starting from empty, building structure with addRow/addCol,
--   then populating with update()
-- -----------------------------------------------------------------------

local function makeDynamic(anchorX, anchorY)
  local f = window("Dynamic Table", 320, 180, anchorX, anchorY)

  local t = TableFrame:new{
    parent       = f,
    cellWidth    = 90,
    cellHeight   = 20,
    headerHeight = 22,
    -- non-nil so offsets are computed correctly before addRow/addCol are called
    rowNames     = {},
    headerWidth  = 70,
    colNames     = {},
  }
  t:SetPoint("TOPLEFT", f._widget, "TOPLEFT", 8, -38)

  -- build structure dynamically
  t:addCol{name = "Item",     width = 140}
  t:addCol{name = "Count",    width = 70,  justifyH = "RIGHT"}
  t:addCol{name = "Equipped", width = 80,  justifyH = "CENTER"}

  t:addRow{name = "Weapons"}
  t:addRow{name = "Armor"}
  t:addRow{name = "Trinkets"}

  t.data = {
    {"Thunderfury",    "1", "Yes"},
    {"Sulfuras",       "1", "No"},
    {"Eye of Sulfuras","2", "Yes"},
  }
  t:update()
  f:Size(t:Width() + 16, t:Height() + 46)

  return f
end

-- -----------------------------------------------------------------------
-- Public API
-- -----------------------------------------------------------------------

function Test.run()
  if #windows > 0 then
    for _, w in ipairs(windows) do w:Toggle() end
    return
  end

  -- stagger windows: column 1 left-of-centre, column 2 right-of-centre
  windows[1] = makeBasicColumns(  -190,  130)
  windows[2] = makeRowAndColHeaders(210, 130)
  windows[3] = makeAutosize(      -190, -80)
  windows[4] = makeDynamic(        210, -80)
end
