# -*- ruby -*-

require 'pathname'
require 'rubygems'

require 'mixins' unless defined?( Mixins )


# Adds a #data_dir method and a DATA_DIR constant to extended objects. These
# will be set to the `Pathname` to the data directory distributed with a gem of the
# name derived from the `#name` of the extended object. Prefers environmental
# override, Gem path, then local filesystem pathing.
#
# This can also be called manually if the including class name doesn't
# match the gem, or something else esoteric.
#
#     require 'mixins'
#
#     class Acme
#         extend Mixins::Datadir
#     end
#
#     # When loading from checked-out source
#     Rhizos.data_dir
#     # => #<Pathname:../data/acme>
#
#     # With ACME_DATADIR=/path/to/data set in the environment before Ruby starts:
#     Rhizos.data_dir
#     # => #<Pathname:/path/to/data>
#
#     # When installed via gem
#     Rhizos.data_dir
#     # => #<Pathname:/path/to/lib/ruby/gems/3.4.0/gems/acme-1.0.0/data/acme>
#
module Mixins::Datadir

	### Extend hook: Set up the `data_dir` accessor and the `DATA_DIR` constant
	###
	def self::extended( obj )
		name = obj.name.downcase.gsub( '::', '-' )
		dir = self.find_datadir( name )

		obj.const_set( :DATA_DIR, dir )
		obj.singleton_class.attr_accessor :data_dir
		obj.data_dir = dir
	end


	### Return a pathname object for the gem data directory. Use the `<gemname>_DATADIR`
	### environment variable if it's set, or the data directory of the loaded gem if
	### there is one. If neither of those are set, fall back to a relative path of
	### `../../data/<gemname>`. You can override which environment variable is used for
	### the override by setting +env+.
	###
	def self::find_datadir( gemname, env: nil )
		unless env
			comps = gemname.split( '-' )
			env = comps.size > 1 ? comps.last : comps.first
			env = "%s_DATADIR" % [ env.upcase ]
		end

		loaded_gemspec = Gem.loaded_specs[ gemname ]

		dir = if ENV[ env ]
				Pathname( ENV[ env ] )
			elsif loaded_gemspec && File.exist?( loaded_gemspec.datadir )
				Pathname( loaded_gemspec.datadir )
			else
				caller_path = caller_locations( 2, 1 ).first.absolute_path
				Pathname( caller_path ).dirname.parent + "data/#{gemname}"
			end

		return dir
	end

end # module Mixins::Datadir
