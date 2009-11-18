default:


db:
	create_db liquid_feedback
	psql liquid_feedback -f db/core.sql

demo-db: db
	psql liquid_feedback -f db/demo.sql


translations-de:
	cd ../webmcp/framework/bin/ && ./langtool.lua ~/workspace/liquid_feedback/locale/translations.de.lua ~/workspace/liquid_feedback/app ~/workspace/liquid_feedback/locale/translations.de.lua

