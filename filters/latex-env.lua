-- List of float environment names (must match their CSS classes)
local float_environments = {
    "figure",
    "table",
    "listing",
}

-- Build a lookup set for faster membership testing
local float_set = {}
for _, env in ipairs(float_environments) do
    float_set[env] = true
end

local function float_with_placement(el)
    -- Check if any of the div's classes match our float environments
    for _, class in ipairs(el.classes) do
        if float_set[class] then
            local environment = class
            local placement = el.attributes["placement"] or "h"
            
            if FORMAT == "latex" or FORMAT == "beamer" then
                local float_env = {
                    pandoc.RawBlock("latex", "\\begin{" .. environment .. "}[" .. placement .. "]"),
                    pandoc.RawBlock("latex", "\\centering"),
                }
                
                -- Separate caption from other content
                local caption = nil
                local other_content = {}
                
                for _, block in ipairs(el.content) do
                    if
                        block.t == "Para"
                        and #block.content > 0
                        and block.content[1].t == "Str"
                        and block.content[1].text:match("^[Cc]aption:$")
                    then
                        local caption_inlines = {}
                        for i = 2, #block.content do
                            table.insert(caption_inlines, block.content[i])
                        end
                        if #caption_inlines > 0 then
                            caption = pandoc.Inlines(caption_inlines)
                        end
                    else
                        table.insert(other_content, block)
                    end
                end
                
                -- Add non-caption content
                for _, block in ipairs(other_content) do
                    table.insert(float_env, block)
                end
                
                -- Add caption with label if specified
                if caption then
                    local caption_str = pandoc.utils.stringify(caption)
                    local label = el.attributes["label"]
                    if label then
                        table.insert(
                            float_env,
                            pandoc.RawBlock("latex", "\\caption{\\label{" .. label .. "}" .. caption_str .. "}")
                        )
                    else
                        table.insert(float_env, pandoc.RawBlock("latex", "\\caption{" .. caption_str .. "}"))
                    end
                end
                
                table.insert(float_env, pandoc.RawBlock("latex", "\\end{" .. environment .. "}"))
                return float_env
            end
        end
    end
    return nil
end

return {
    { Div = float_with_placement },
}
