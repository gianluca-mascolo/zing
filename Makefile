.DEFAULT_GOAL := zing

.PHONY: clean
clean:
	rm -f zing.o zing
zing:
	@zig build-exe zing.zig
