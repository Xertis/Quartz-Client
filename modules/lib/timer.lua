local module = {}
local tasks = {}

function module.add_task(job, _time, delay, ...)
    table.insert(tasks, {
        job = job,
        time = _time,
        delay = delay or 0,
        start_time = time.uptime(),
        data = {...},

        last_start = 0
    })
end

function module.__tick()
    local cur_time = time.uptime()

    for i=#tasks, 1, -1 do
        local task = tasks[i]

        if task.start_time + task.time < cur_time then
            table.remove(tasks, i)
        else
            if cur_time - task.last_start > task.delay then
                task.data = {task.job(unpack(task.data))}
                task.last_start = cur_time
            end
        end
    end
end

return module