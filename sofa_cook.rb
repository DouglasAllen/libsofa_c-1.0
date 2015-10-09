require "mini_portile"


recipe1 = MiniPortile.new("libsofa_c", "1.0")
recipe1.files = ["https://github.com/DouglasAllen/libsofa_c-1.0/raw/master/libsofa_c-1.0.tar"]
recipe1.download
recipe1.extract
recipe1.compile
recipe1.install unless recipe1.installed?
recipe1.activate
