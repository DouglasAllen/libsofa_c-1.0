require "mini_portile"
require 'mkmf'
p ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
# ROOT = File.expand_path('../', __FILE__)
recipe = MiniPortile.new("libsofa_c", "1.0")
#recipe1.files = ["https://github.com/DouglasAllen/libsofa_c-1.0/raw/master/libsofa_c-1.0.tar"]
#recipe1.download
#recipe1.extract

recipe.target = portsdir = File.join(ROOT, "ports")

#recipe1.compile
#recipe1.install unless recipe1.installed?
#recipe1.activate



libsofa_recipe = process_recipe("libsofa_c", "1.0", static_p, cross_build_p) do |recipe|
  recipe.files = ["https://github.com/DouglasAllen/libsofa_c-1.0/raw/master/libsofa_c-1.0.tar"]
  recipe.configure_options += [
    "CPPFLAGS='-Wall'",
    "CFLAGS='-O2 -g'",
    "CXXFLAGS='-O2 -g'",
    "LDFLAGS="
   ]
end
