-- docx only: Quarto renders callouts as Word tables, which Word Online (OneDrive)
-- reports as a corrupted file (desktop Word opens it). Replace each callout with
-- plain paragraphs: bold title followed by the callout content.

if not quarto.doc.is_format("docx") then
  return {}
end

local function plain_callout(title, content)
  local blocks = pandoc.List()
  if title and #title > 0 then
    blocks:insert(pandoc.Para({ pandoc.Strong(title) }))
  end
  blocks:extend(content)
  return pandoc.Div(blocks)
end

return {
  {
    -- Quarto >= 1.3 parses callouts into a custom AST node
    Callout = function(el)
      -- title may be a single Block, a list of Blocks or Inlines
      local title = el.title
      if title and pandoc.utils.type(title) == "Block" then
        title = pandoc.utils.blocks_to_inlines({ title })
      elseif title and pandoc.utils.type(title) == "Blocks" then
        title = pandoc.utils.blocks_to_inlines(title)
      end
      return plain_callout(title, el.content)
    end,
    -- Fallback for callouts still as Divs: "## Title" as the first block
    Div = function(el)
      local is_callout = false
      for _, c in ipairs(el.classes) do
        if c:match("^callout") then is_callout = true end
      end
      if not is_callout then return nil end
      local content = pandoc.List(el.content)
      local title = nil
      if content[1] and content[1].t == "Header" then
        title = content[1].content
        content:remove(1)
      elseif el.attributes["title"] then
        title = pandoc.Inlines(el.attributes["title"])
      end
      return plain_callout(title, content)
    end
  }
}
