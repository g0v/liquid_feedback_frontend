PATH:=$(PATH):/opt/rocketwiki-lqfb/

DIRS = help
HTML_SOURCE := $(foreach DIR,$(DIRS),$(wildcard $(DIR)/*.txt))
HTML_HELP := $(HTML_SOURCE:.txt=.txt.html)
TARGET = all


%.txt.html: %.txt
	rocketwiki-lqfb < $< > $@


help_html: $(HTML_HELP)
	echo $(HTML_SOURCE)
	echo $(HTML_HELP)
#	for FILE in help/*.txt; do echo $FILE; rocketwiki-lqfb < $FILE ; done

clean:
	rm -f $(HTML_HELP)

all: help_html
