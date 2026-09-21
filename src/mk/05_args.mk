#
# Args: $(RUN_ARGS), $(FIRST_ARG)
#

RUN_ARGS  := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
FIRST_ARG := $(firstword $(RUN_ARGS))

define accept-args
$(if $(and $(filter $(1),$(firstword $(MAKECMDGOALS))),$(RUN_ARGS)),$(eval $(RUN_ARGS):;@:))
endef
