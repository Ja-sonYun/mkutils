#
# Args: $(RUN_ARGS), $(FIRST_ARG)
#

RUN_ARGS  := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
$(eval $(RUN_ARGS):;@:)
FIRST_ARG := $(firstword $(RUN_ARGS))
