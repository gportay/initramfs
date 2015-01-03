extradir	+= install-at91
packages	+= install-at91/at91-gpio.tgz

install-at91/%.tgz:
	@echo -e "\e[1mBuilding package $*...\e[0m"
	install -d ${@D}
	( cd packages-at91/$* && tar czf ../../$@ --exclude=.gitignore * )

