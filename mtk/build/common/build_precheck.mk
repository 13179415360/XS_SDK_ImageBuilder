# Generic build time check rules

ifneq (1,$(_mtk_build_prechecker_included))
_mtk_build_prechecker_included := 1

################################################################################
# logs/ directory must not exist before building, which means the previous
# "make defconfig" may fail. The check is only performed in target build time,
# that is, when DUMP is not 1, because there are some warnings such as unknown
# CPU_TYPE cortex-a55 that may create logs/ in dump mode.
################################################################################
prereq: $(TMPDIR)/.prereq-check_if_logs_dir_exists
$(TMPDIR)/.prereq-check_if_logs_dir_exists:
	@if [ -d "$(TOPDIR)/logs" ]; then \
		echo 'Error: [check_if_logs_dir_exists] directory "logs/" exists, maybe previous "make defconfig" step fails. Please check the error message in "logs/" to identify the issue. Once everything is ready, remove "logs/" and try again.' >&2; \
		echo >&2; \
		echo 'Top 10 lines of each error log file:' >&2; \
		for i in $$(find $(TOPDIR)/logs -type f); do \
			echo "[$${i}]" >&2; \
			head -n 10 $${i} >&2; \
			echo >&2; \
		done; \
		exit 1; \
	fi
	@touch $@

################################################################################
# If length of TOPDIR is too long, unexpected build error may occur. For
# example libuClibc++ may fail due to missing array_type_info.o.
################################################################################
prereq: $(TMPDIR)/.prereq-check_topdir_max_length
$(TMPDIR)/.prereq-check_topdir_max_length: PRIVATE_TOPDIR_MAX_LENGTH := 87
$(TMPDIR)/.prereq-check_topdir_max_length:
	TOPDIR_LENGTH=`expr length $(TOPDIR)`; \
	if [ $${TOPDIR_LENGTH} -gt $(PRIVATE_TOPDIR_MAX_LENGTH) ]; then \
		echo "$@: ERROR: length of TOPDIR ($(TOPDIR)) is $${TOPDIR_LENGTH}, exceeding limit $(PRIVATE_TOPDIR_MAX_LENGTH)" >&2; \
		exit 1; \
	else \
		echo "$@: PASS: length of TOPDIR ($(TOPDIR)) is $${TOPDIR_LENGTH}, less than/equal to limit $(PRIVATE_TOPDIR_MAX_LENGTH)"; \
		touch $@; \
	fi

endif # build_prechecker included
