local target_rotation = nil
local start_rotation = nil
local current_rotation = nil
local rotation_timer = 0
local rotation_duration = 0.15
local is_rotating = false

local tsf = entity.transform
local body = entity.rigidbody

local function set_pos(target_pos)
    local current_pos = tsf:get_pos()
    local direction = vec3.sub(target_pos, current_pos)
    local distance = vec3.length(direction)

    if distance > 10 or distance < 0.01 then
        tsf:set_pos(target_pos)
        if body then
            body:set_vel({0, 0, 0})
        end
    elseif body then
        local time_to_reach = 0.1
        local velocity = vec3.mul(vec3.normalize(direction), distance / time_to_reach)
        body:set_vel(velocity)
    end
end

local function set_rot(rot_mat)

    local new_target = quat.from_mat4(rot_mat)

    start_rotation = quat.from_mat4(tsf:get_rot())

    target_rotation = new_target
    rotation_timer = 0
    is_rotating = true
end

return {
    on_render = function(delta)
        if not is_rotating or not target_rotation then
            return
        end

        rotation_timer = rotation_timer + delta

        local t = rotation_timer / rotation_duration

        if t >= 1 then

            tsf:set_rot(mat4.from_quat(target_rotation))
            is_rotating = false
            return
        end

        local interpolated = quat.slerp(start_rotation, target_rotation, t)

        tsf:set_rot(mat4.from_quat(interpolated))
    end,

    set_pos = set_pos,
    set_rot = function(rot_mat)
        if is_rotating then
            rotation_duration = 0.1
        end
        set_rot(rot_mat)
    end,

    set_rotation_speed = function(speed_ms)
        rotation_duration = speed_ms / 1000
    end
}