# -*- ruby -*-

require 'pathname'
require 'rubygems'

require 'mixins' unless defined?( Mixins )


# When extended in a class, automatically set the path to a DATA_DIR
# constant, derived from the class name.  Prefers environmental
# override, Gem path, then local filesystem pathing.
#
# This can also be called manually if the including class name doesn't
# match the gem, or something else esoteric.
#
# DATA_DIR is a Pathname object.
#
module Mixins::Datadir

	### Extend hook: Set the DATA_DIR constant in the extending
	### class.
	###
	def self::extended( obj )
		name = obj.name.downcase.gsub( '::', '-' )
		dir = self.find_datadir( name )

		obj.const_set( :DATA_DIR, dir )
		obj.singleton_class.attr_accessor :data_dir
		obj.data_dir = dir
	end


	### Return a pathname object for the extended class DATA_DIR.  This
	### allows for the DATA_DIR constant to be used transparently between
	### development (local checkout) and production (gem installation)
	### environments.
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
				Pathname( caller_path ).dirname.parent.parent + "data/#{gemname}"
			end

		return dir
	end

end # module Mixins::Datadir
