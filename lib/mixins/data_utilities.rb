# -*- ruby -*-

require 'tempfile'

require 'mixins' unless defined?( Mixins )


# A collection of miscellaneous functions that are useful for manipulating
# complex data structures.
#
#   include Ravn::DataUtilities
#   newhash = deep_copy( oldhash )
#
module Mixins::DataUtilities

	###############
	module_function
	###############


	### Recursively copy the specified +obj+ and return the result.
	def deep_copy( obj )

		# Handle mocks during testing
		return obj if obj.class.name == 'RSpec::Mocks::Mock'

		# rubocop:disable Layout/IndentationWidth, Layout/IndentationStyle
		return case obj
			when NilClass, Numeric, TrueClass, FalseClass, Symbol,
			     Module, Encoding, IO, Tempfile
				obj

			when Array
				obj.map {|o| deep_copy(o) }

			when Hash
				newhash = {}
				newhash.default_proc = obj.default_proc if obj.default_proc
				obj.each do |k,v|
					newhash[ deep_copy(k) ] = deep_copy( v )
				end
				newhash

			else
				obj.clone
			end
			# rubocop:enable Layout/IndentationWidth, Layout/IndentationStyle
	end


	### Return a duplicate of the given +object+ with its Symbol keys transformed
	### into Strings.
	def stringify_keys( object )
		case object
		when Hash
			return object.each_with_object( {} ) do |(key,val), newhash|
				key = key.to_s if key.is_a?( Symbol )
				newhash[ key ] = stringify_keys( val )
			end
		when Array
			return object.map {|el| stringify_keys(el) }
		else
			return object
		end
	end


	### Return a duplicate of the given +object+ with its identifier-like String keys
	### transformed into Symbols.
	def symbolify_keys( object )
		case object
		when Hash
			return object.each_with_object( {} ) do |(key,val), newhash|
				key = key.to_sym if key.respond_to?( :to_sym ) &&
					key.match?( /\A\w+\Z/ )
				newhash[ key ] = symbolify_keys( val )
			end
		when Array
			return object.map {|el| symbolify_keys(el) }
		else
			return object
		end
	end
	alias_method :internify_keys, :symbolify_keys

end # module Mixins::DataUtilities


