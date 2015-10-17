require "mini_portile"
require 'mkmf'
#ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
ROOT = File.expand_path('../', __FILE__)
#recipe1 = MiniPortile.new("libsofa_c", "1.0")
#recipe1.files = ["https://github.com/DouglasAllen/libsofa_c-1.0/raw/master/libsofa_c-1.0.tar"]
#recipe1.download
#recipe1.extract

#recipe1.target = portsdir = File.join(ROOT, "ports")

#recipe1.compile
#recipe1.install unless recipe1.installed?
#recipe1.activate

def nokogiri_try_compile
  args = if defined?(RUBY_VERSION) && RUBY_VERSION <= "1.9.2"
           ["int main() {return 0;}"]
         else
           ["int main() {return 0;}", "", {werror: true}]
         end
  try_compile(*args)
end


def add_cflags(flags)
  print "checking if the C compiler accepts #{flags}... "
  with_cflags("#{$CFLAGS} #{flags}") do
    if nokogiri_try_compile
      puts 'yes'
      true
    else
      puts 'no'
      false
    end
  end
end

def preserving_globals
  values = [
    $arg_config,
    $CFLAGS, $CPPFLAGS,
    $LDFLAGS, $LIBPATH, $libs
  ].map(&:dup)
  yield
ensure
  $arg_config,
  $CFLAGS, $CPPFLAGS,
  $LDFLAGS, $LIBPATH, $libs =
    values
end
def process_recipe(name, version, static_p, cross_p)
  MiniPortile.new(name, version).tap do |recipe|
    recipe.target = portsdir = File.join(ROOT, "ports")
    # Prefer host_alias over host in order to use i586-mingw32msvc as
    # correct compiler prefix for cross build, but use host if not set.
    recipe.host = RbConfig::CONFIG["host_alias"].empty? ? RbConfig::CONFIG["host"] : RbConfig::CONFIG["host_alias"]
    recipe.patch_files = Dir[File.join(portsdir, "patches", name, "*.patch")].sort

    yield recipe

    env = Hash.new { |hash, key|
      hash[key] = "#{ENV[key]}"  # (ENV[key].dup rescue '')
    }

    recipe.configure_options.flatten!

    recipe.configure_options.delete_if { |option|
      case option.shellsplit.first
      when /\A(\w+)=(.*)\z/
        env[$1] = $2
        true
      else
        false
      end
    }

    if static_p
      recipe.configure_options += [
        "--disable-shared",
        "--enable-static",
      ]
      env['CFLAGS'] = "-fPIC #{env['CFLAGS']}"
    else
      recipe.configure_options += [
        "--enable-shared",
        "--disable-static",
      ]
    end

    if cross_p
      recipe.configure_options += [
        "--target=#{recipe.host}",
        "--host=#{recipe.host}",
      ]
    end

    if RbConfig::CONFIG['target_cpu'] == 'universal'
      %w[CFLAGS LDFLAGS].each { |key|
        unless env[key].shellsplit.include?('-arch')
          env[key] << ' ' << RbConfig::CONFIG['ARCH_FLAG']
        end
      }
    end

    recipe.configure_options += env.map { |key, value|
      "#{key}=#{value}".shellescape
    }

    message <<-"EOS"
************************************************************************


    message <<-"EOS"
************************************************************************
    EOS

    p checkpoint = "#{recipe.target}/#{recipe.name}-#{recipe.version}-#{recipe.host}.installed"
    unless File.exist?(checkpoint)
      #recipe.cook
      recipe.download
      recipe.extract
      recipe.compile
      recipe.install unless recipe1.installed?
      FileUtils.touch checkpoint
    end
    #recipe.activate
  end
end

RbConfig::MAKEFILE_CONFIG['CC'] = ENV['CC'] if ENV['CC']

if defined?(RUBY_ENGINE) && RUBY_ENGINE == 'macruby'
  $LIBRUBYARG_STATIC.gsub!(/-static/, '')
end


$LIBS << " #{ENV["LIBS"]}"

# Read CFLAGS from ENV and make sure compiling works.
add_cflags(ENV["CFLAGS"])

case RbConfig::CONFIG['target_os']
when 'mingw32', /mswin/
  windows_p = true
  $CFLAGS << " -DXP_WIN -DXP_WIN32 -DUSE_INCLUDED_VASPRINTF"
when /solaris/
  $CFLAGS << " -DUSE_INCLUDED_VASPRINTF"
when /darwin/
  darwin_p = true
  # Let Apple LLVM/clang 5.1 ignore unknown compiler flags
  add_cflags("-Wno-error=unused-command-line-argument-hard-error-in-future")
else
  $CFLAGS << " -g -DXP_UNIX"
end

if RUBY_PLATFORM =~ /mingw/i
  # Work around a character escaping bug in MSYS by passing an arbitrary
  # double quoted parameter to gcc. See https://sourceforge.net/p/mingw/bugs/2142
  $CPPFLAGS << ' "-Idummypath"'
end

if RbConfig::MAKEFILE_CONFIG['CC'] =~ /gcc/
  $CFLAGS << " -O3" unless $CFLAGS[/-O\d/]
  $CFLAGS << " -Wall -Wcast-qual -Wwrite-strings -Wconversion -Wmissing-noreturn -Winline"
end

static_p = enable_config('static', true) or
    message "Static linking is disabled.\n"
cross_build_p = enable_config("cross-build")
libsofa_recipe = process_recipe("libsofa_c", "1.0", static_p, cross_build_p) do |recipe|
  recipe.files = ["https://github.com/DouglasAllen/libsofa_c-1.0/raw/master/libsofa_c-1.0.tar"]
  recipe.configure_options += [
    "CPPFLAGS='-Wall'",
    "CFLAGS='-O2 -g'",
    "CXXFLAGS='-O2 -g'",
    "LDFLAGS="
   ]
  end

#create_makefile('helio')
