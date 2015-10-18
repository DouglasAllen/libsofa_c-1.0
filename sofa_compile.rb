require "mini_portile"

# get the sofa c src and docs
# recipe2 = MiniPortile.new("libsofa_c", "1.0")
# recipe2.files = ["http://www.iausofa.org/2009_0201_C/sofa_c-20090201_c.tar.gz"]
# recipe2.download
# recipe2.extract

recipe1 = MiniPortile.new("libsofa_c", "1.0")
recipe1.files = ["https://github.com/DouglasAllen/libsofa_c-1.0/raw/master/libsofa_c-1.0.tar"]
recipe1.download
recipe1.extract
# recipe1.compile
# recipe1.install unless recipe1.installed?
# recipe1.activate
