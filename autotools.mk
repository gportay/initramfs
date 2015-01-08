%/configure: %/configure.ac
	@echo -e "\e[1mAutoConfiguring $(@D)...\e[0m"
	( cd $(@D) && autoreconf -vif )

