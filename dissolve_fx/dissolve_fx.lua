-- Dissolve FX
-- ###########
-- 
-- * Add two textures to your sprite atlas: `noise` and `ramp`. The noise will be used to animate the sprite's dissolve, and the ramp will be used to create the burning effect.
-- * Set `dissolve_fx/materials/sprite.material` as the material of the sprite.
-- * Finally, write some code in your script:
-- 
-- local dissolve_fx = require("dissolve_fx.dissolve_fx")
-- 
-- function init(self)
--     dissolve_fx.init("#sprite", "noise", 1) -- args: sprite component with dissolve material, noise image name, a scale of the noise texture
--     go.set("#sprite", "dissolve.z", 0.25) -- size of the fire. Adjust subjectively to your eye!
--     go.set("#sprite", "glow_color", vmath.vector4(0.0, 0.5, 1.0, 0)) -- color of the fx (R 1.0, G 0.5, B 0.0 - default value)
--     go.set("#sprite", "dissolve.w", 0.0) -- to control the fx, 0.0 - 1.0, (0.0 is turn off, doesn't calculate in the shader)
-- 
--     -- Play the FX in the loop
--     go.animate("#sprite", "dissolve.w", go.PLAYBACK_LOOP_PINGPONG, 1, go.EASING_LINEAR, 3)
-- end
--

local M = {}

function M.find_uvrect(sprite_url, image_id, scale, scale_mode)
    assert(type(image_id) == "string", "`image_id` should be a string")
    local scale_mode = scale_mode or "stretch"
    local atlas = go.get(sprite_url, "image")
    local atlas_data = resource.get_atlas(atlas)
    local tex_info = resource.get_texture_info(atlas_data.texture)
    local scale = scale or 1

    local image_num
    for i, animation in ipairs(atlas_data.animations) do
        if animation.id == image_id then
            image_num = i
            break
        end
    end
    assert(image_num, "Unable to find image " .. image_id)

    local uvs = atlas_data.geometries[image_num].uvs
    assert(#uvs == 8, "Sprite trim mode should be disabled for the noise and ramp images.")

    local tex_w = tex_info.width
    local tex_h = tex_info.height

    local position_x = uvs[1]
    local position_y = uvs[6]
    local width = uvs[5] - uvs[1]
    local height = uvs[2] - uvs[6]

    if height < 0 then
        -- In case the atlas builder has flipped the sprite to optimise the space.
        position_y = uvs[2]
        height = uvs[6] - uvs[2]
    end

    local w = width / tex_w / scale
    local h = height / tex_h / scale

    local sprite_image_id = go.get(sprite_url, "animation")
    for _, animation in ipairs(atlas_data.animations) do
        if hash(animation.id) == sprite_image_id then
            if scale_mode == "stretch" then
                w = w / animation.width
                h = h / animation.height
            else -- cover
                local max = math.max(animation.width, animation.height)
                w = w / max
                h = h / max
            end
            break
        end
    end
    
    
    return (position_x + width/2) / tex_w,         -- x + w/2
        (tex_h - (position_y + height/2)) / tex_h, -- y + h/2
        w ,                                        -- w
        h                                          -- h
end

function M.init(sprite_url, noise_image, scale)
    go.set(sprite_url, "noise_uvrect", vmath.vector4(M.find_uvrect(sprite_url, noise_image, scale)))
end

return M