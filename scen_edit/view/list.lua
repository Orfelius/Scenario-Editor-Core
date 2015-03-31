List = LCS.class{}

function List:init()
    self.panel = ScrollPanel:New {
        x = 0,
        y = 0,
        bottom = 0,
        right = 0,
        borderColor = {0,0,0,0},
        horizontalScrollbar = false,
    }

    self.ctrl = Control:New {
        x = 0,
        right = 0,
        y = 0,
        bottom = 0,
        padding = {0, 0, 0, 0},
        children = {
            self.panel,
        },
    }

    self.itemPanelMapping = {}
    self.orderPanelMapping = {}
end

function List:Clear()
    self.panel:ClearChildren()
end

function List:AddRow(items, id)
    local w = items[#items].x + items[#items].width
    local h = 40
    local padding = 15

    local container = Control:New {
        width = w,
        y = 0,
        height = h,
        padding = {0, 0, 0, 0},
        children = items,
    }
    local panel = LayoutPanel:New {
        x = 0,
        right = 0,
        height = h,
        padding = {0, 0, 0, 0},
        itemMargin = {0, 0, 0, 0},
        itemPadding = {0, 0, 0, 0},
        children = { container },
    }

    local index = #self.panel.children + 1
    local w = Window:New {
        x = 0,
        right = 0,
        y = self:CalculateHeight(index),
        height = h,
        children = { panel },
        resizable = false,
        draggable = false,
        padding= {0, 0, 0, 0},
        id = id,
        index = index
    }
    self.panel:AddChild(w)
    self.itemPanelMapping[id] = w
    self.orderPanelMapping[index] = w

    self:RecalculatePosition(id)
end

function List:GetRowItems(id)
    local panel = self.itemPanelMapping[id]
    return panel.children[1].children[1].children
end

function List:CalculateHeight(index)
    local h = 40
    local padding = 15
    return 10 + (index - 1) * (h + padding)
end

-- res >  0: id1 before id2
-- res == 0: equal
-- res <  0: id2 before id1
function List:CompareItems(id1, id2)
    return 0
end

function List:SwapPlaces(panel1, panel2)
    tmp = panel1.index

    panel1.index = panel2.index
    self.orderPanelMapping[panel1.index] = panel1
    panel1.y = self:CalculateHeight(panel1.index)
    panel1:Invalidate()

    panel2.index = tmp
    self.orderPanelMapping[panel2.index] = panel2
    panel2.y = self:CalculateHeight(panel2.index)
    panel2:Invalidate()
end

function List:RecalculatePosition(id)
    local panel = self.itemPanelMapping[id]
    local index = panel.index

    -- move panel up if needed
    while panel.index > 1 do
        local panel2 = self.orderPanelMapping[panel.index - 1]
        if self:CompareItems(panel.id, panel2.id) > 0 then
            self:SwapPlaces(panel, panel2)
        else
            break
        end
    end
    -- move panel down if needed
    while panel.index < #self.panel.children - 1 do
        local panel2 = self.orderPanelMapping[panel.index + 1]
        if self:CompareItems(panel.id, panel2.id) < 0 then
            self:SwapPlaces(panel, panel2)
        else
            break
        end
    end
end

function List:RemoveRow(id)
    local panel = self.itemPanelMapping[id]
    local index = panel.index

    -- move elements up
    while index < #self.panel.children do
        local pnl = self.orderPanelMapping[index + 1]
        pnl.index = index
        pnl.y = self:CalculateHeight(pnl.index)
        self.orderPanelMapping[index] = pnl
        pnl:Invalidate()

        index = index + 1
    end
    self.orderPanelMapping[index] = nil

    self.panel:RemoveChild(panel)
    self.itemPanelMapping[id] = nil
end