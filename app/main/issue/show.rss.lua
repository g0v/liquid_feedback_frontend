slot.set_layout("rss")

local function rss_channel(channel)
  for key, val in pairs(channel) do
    slot.put("<", key, ">", encode.html(val), "</", key, ">")
  end
end

local function rss_item(item)
  slot.put("<item>")
  for key, val in pairs(item) do
    slot.put("<", key, ">", encode.html(val), "</", key, ">")
  end
  slot.put("</item>")
end


local issue = Issue:by_id(param.get_id())

rss_channel{
  title = issue.area.name .. " :: Issue #" .. tostring(issue.id),
  language = "de",
  pubDate = "Tue, 8 Jul 2008 2:43:19"
}

for i, initiative in ipairs(issue.initiatives) do
  rss_item{
    title = initiative.name,
    description = initiative.current_draft.content,
    link = "http://localhost/lf/initiative/show/" .. tostring(initiative.id) .. ".html",
    author = initiative.current_draft.author.name,
    guid = "guid",
    pubDate = "Tue, 8 Jul 2008 2:43:19"
  }
end