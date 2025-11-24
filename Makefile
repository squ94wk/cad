OPENSCAD := openscad
OPENSCAD_FLAGS := --export-format binstl

# Find all .scad files
SCAD_FILES := $(shell find . -name '*.scad' -not -path '*/.*' -not -path '*/models/*')

# Generate output paths: ./dir/file.scad -> models/out/dir/file.stl
STL_FILES := $(patsubst ./%.scad,models/out/%.stl,$(SCAD_FILES))

.PHONY: all clean

all: $(STL_FILES)

models/out/%.stl: %.scad
	@mkdir -p $(dir $@)
	$(OPENSCAD) $(OPENSCAD_FLAGS) -o $@ $<

clean:
	rm -rf models/out/

.SUFFIXES:
