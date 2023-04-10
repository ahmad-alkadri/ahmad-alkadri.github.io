.PHONY: new

new:
	$(eval name := $(shell read -p "Enter file name: " fname && echo $$fname))
