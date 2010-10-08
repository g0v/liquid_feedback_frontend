
app.html_title = {}

  execute.inner()

-- add ":" to prefix
if app.html_title.prefix then
	app.html_title.prefix = app.html_title.prefix .. ": " 
	app.html_title.prefix = encode.html( app.html_title.prefix )
end

-- add "-" to title 
if app.html_title.title then
	app.html_title.title = app.html_title.title .. " - " 
	app.html_title.title = encode.html( app.html_title.title )
-- or pull from <h1>title<h1> 
-- but only if it does not contain config.app_title
-- (otherwise config.app_title would appear twice in title)
elseif slot.get_content( "title" ) ~= encode.html( config.app_title ) then
  -- replace all html from the title first
	app.html_title.title = string.gsub(slot.get_content( "title" ), "</?[A-Za-z][A-Za-z0-9:_%-]*[^>]*>", ""):gsub("%s+", " ") .. " - "
end

-- add "-" to subtitle
if app.html_title.subtitle then
	app.html_title.subtitle = app.html_title.subtitle .. " - " 
	app.html_title.subtitle = encode.html( app.html_title.subtitle )
end


--slot.put_into("html_title", encode.html( config.app_title ) )
slot.put_into("html_title", 
	( app.html_title.prefix or "" )
	..
	( app.html_title.title  or "" )
	..
	( app.html_title.subtitle or "" )
	..
	config.app_title
)


--[[

[prefix: ]main - [subtitle - ]appname


Aktueller Entwurf:
	Pro BGE - Initiative #33 - Liquidfeedback PP Dtl.
Anregungen zu: Pro BGE - Initiative #33 - Liquidfeedback PP Dtl.
Entwurfshistorie zu: Pro BGE - Initiative #33 - Liquidfeedback PP Dtl.
Details zu: Pro BGE - Initiative #33 - Liquidfeedback PP Dtl.

Thema #34 - Liquidfeedback Dtl.


Themenbereiche - Liquidfeedback Dtl

Wirtschaft & Soziales - Themenbereich - Liquidfeedback Piratenpartei Deutschland
Wirtschaft & Soziales - Liquidfeedback Piratenpartei Deutschland

Standard proceeding - Regelwerk - Piratenpartei Deutschland

Registrierung - Piratenpartei Deutschland


Mitgliederliste - Piratenpartei Deutschland

Administrator - Mitglied - Piratenpartei Deutschland



--]]

--slot.put_into("html_title", slot.get_content("title") .. config.app.html_title)
--print (slot.get_content("title"))
--exit()
