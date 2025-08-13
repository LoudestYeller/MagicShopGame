local M = {}

function M.MountAtSocket(shell: Model, socketName: string, station: Model)
    local socket = shell:FindFirstChild(socketName, true)
    if not (socket and socket:IsA("Attachment")) then
        warn("[SocketBinder] Missing socket:", socketName)
        return false
    end
    if not station.PrimaryPart then
        warn("[SocketBinder] Station has no PrimaryPart:", station.Name)
        return false
    end
    local size = station:GetExtentsSize()
    local lift = Vector3.new(0, size.Y * 0.5, 0)
    station:PivotTo(socket.WorldCFrame + lift)
    station.Parent = shell
    return true
end

return M