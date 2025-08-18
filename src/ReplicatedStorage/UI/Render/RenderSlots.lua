--!strict
-- Stateless renderer for display slots with selection
local SlotCard = require(script.Parent.Parent.Components.SlotCard)

local M = {}

export type Slot = {
    slotId: number,
    itemId: string | number,
    qty: number,
    price: number?,
    icon: string?,
    name: string?,
}

export type Options = {
    selectedId: number?,
    onSelect: ((number, Slot) -> ())?,
}

local function clear(container: Instance)
    for _, c in ipairs(container:GetChildren()) do
        if not c:IsA("UIGridLayout") and c.Name ~= "EmptyLabel" then
            c:Destroy()
        end
    end
end

function M.render(theme: any, container: Instance, slots: { [number]: Slot }?, opts: Options?)
    clear(container)

    local count = 0
    for id, slot in pairs(slots or {}) do
        count += 1
        local card = SlotCard.create(theme, {
            slotId = slot.slotId or id,
            name = slot.name or tostring(slot.itemId),
            icon = slot.icon,
            qty = slot.qty or 1,
            price = slot.price,
            selected = (opts and opts.selectedId == (slot.slotId or id)) or false,
            onActivated = function(cardFrame: Frame)
                -- deselect others
                for _, other in ipairs(container:GetChildren()) do
                    if SlotCard.isCard(other) and other ~= cardFrame then
                        SlotCard.setSelected(other :: Frame, false)
                    end
                end
                SlotCard.setSelected(cardFrame, true)
                local sid = (cardFrame:GetAttribute("SlotId") :: number?) or id
                if opts and opts.onSelect then
                    opts.onSelect(sid :: number, slot)
                end
            end,
        })
        card.Name = ("Slot_%s"):format(slot.slotId or id)
        card.Parent = container
    end

    local empty = container:FindFirstChild("EmptyLabel") :: TextLabel?
    if empty then empty.Visible = (count == 0) end
end

return M