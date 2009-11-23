function format.wiki_text(wiki_text)
  local html, errmsg, exitcode = assert(
    os.pfilter(wiki_text, config.wiki_parser_executeable)
  )
  if exitcode > 0 then
    error("Wiki parser process returned with error code " .. tostring(exitcode))
  elseif exitcode < 0 then
    error("Wiki parser process was terminated by signal " .. tostring(-exitcode))
  end
  return html
end
