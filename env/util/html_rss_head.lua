function util.html_rss_head(args)
  slot.put_into("html_head", '<link rel="alternate" type="application/rss+xml" title="' .. encode.html(args.title) .. '" href="' .. encode.url{ module = args.module, view = args.view, id = args.id, params = args.params } .. '">')
end
