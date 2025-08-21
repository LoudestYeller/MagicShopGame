local Guard = {}
function Guard.loop(name, fn, delay)
    task.spawn(function()
        while true do
            local ok, err = pcall(fn)
            if not ok then warn(("[Guard:%s] %s"):format(name, err)) end
            task.wait(delay or 10)
        end
    end)
end
return Guard