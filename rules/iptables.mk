# iptables package

IPTABLES_VERSION = 1.8.2
IPTABLES_VERSION_FULL = ${IPTABLES_VERSION}-4

IPTABLES = iptables_$(IPTABLES_VERSION_FULL)_$(CONFIGURED_ARCH).deb
$(IPTABLES)_SRC_PATH = $(SRC_PATH)/iptables
SONIC_MAKE_DEBS += $(IPTABLES)

IPTABLESIP4TC = libip4tc0_$(IPTABLES_VERSION_FULL)_$(CONFIGURED_ARCH).deb
$(eval $(call add_derived_package,$(IPTABLES),$(IPTABLESIP4TC)))

IPTABLESIP6TC = libip6tc0_$(IPTABLES_VERSION_FULL)_$(CONFIGURED_ARCH).deb
$(eval $(call add_derived_package,$(IPTABLES),$(IPTABLESIP6TC)))

IPTABLESIPTC = libiptc0_$(IPTABLES_VERSION_FULL)_$(CONFIGURED_ARCH).deb
$(eval $(call add_derived_package,$(IPTABLES),$(IPTABLESIPTC)))

IPXTABLES12 = libxtables12_$(IPTABLES_VERSION_FULL)_$(CONFIGURED_ARCH).deb
$(eval $(call add_derived_package,$(IPTABLES),$(IPXTABLES12)))

# Export these variables so they can be used in a sub-make
export IPTABLES_VERSION
export IPTABLES_VERSION_FULL
export IPTABLES
