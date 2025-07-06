# args.mk - Handle command line arguments in Makefile

# make $(target) -- [args]
# [args] are can be accessed via $(RUN_ARGS)
RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
$(eval $(RUN_ARGS):;@:)

.PHONY: all clean test
