%/configure: %/configure.ac
	@echo "AutoConfiguring $(@D)..."
	( cd $(@D) && autoreconf -vif )

