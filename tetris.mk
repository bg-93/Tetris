EXERCISES += tetris
CLEAN_FILES += tetris

tetris: tetris.c
	$(CC) -o $@ $<

.PHONY: submit give

submit give: tetris.s
	give cs1521 ass1_tetris tetris.s

.PHONY: test autotest

test autotest: tetris.s
	1521 autotest tetris
