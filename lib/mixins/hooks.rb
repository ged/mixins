# -*- ruby -*-

require 'mixins' unless defined?( Mixins )


# Methods for declaring hook methods.
#
#     class MyClass
#         extend Mixins::Hooks
#
#         define_hook :before_fork
#         define_hook :after_fork
#     end
#
#     MyClass.before_fork do
#         @socket.close
#     end
#     MyClass.after_fork do
#         @socket = Socket.new
#     end
#
#     MyClass.run_before_fork_hook
#     fork do
#         MyClass.run_after_fork_hook
#     end
#
#
module Mixins::Hooks

	### Extension callback -- also extend it with MethodUtilities
	def self::extended( obj )
		super
		obj.extend( Mixins::MethodUtilities )
	end


	### Create the body of a method that can register a callback for the specified +hook+.
	def self::make_registration_method( callbackset, **options )
		return lambda do |&callback|
			raise LocalJumpError, "no callback given" unless callback
			set = self.public_send( callbackset ) or raise "No hook registration set!"
			set.add( callback )

			callback.call if self.public_send( "#{callbackset}_run?" )
		end
	end


	### Create the body of a method that calls the callbacks of the given +hook+.
	def self::make_hook_method( callbackset, **options )
		return lambda do |*args|
			set = self.public_send( callbackset ) or raise "No hook callback registration set!"

			self.public_send( "#{callbackset}_run=", true )

			set.to_a.each do |callback|
				callback.call( *args )
			end
		end
	end


	### Define a hook with the given +name+ that can be registered by calling the
	### method of the same +name+ and then run by calling #call_<name>_hooks.
	def define_hook( name, **options )
		callbacks_name = "#{name}_callbacks"
		self.instance_variable_set( "@#{callbacks_name}", Set.new )
		self.singleton_attr_reader( callbacks_name )
		self.instance_variable_set( "@#{callbacks_name}_run", false )
		self.singleton_predicate_accessor( "#{callbacks_name}_run" )

		register_body = Mixins::Hooks.
			make_registration_method( callbacks_name, **options )
		self.singleton_class.define_method( name, &register_body )

		calling_body = Mixins::Hooks.
			make_hook_method( callbacks_name, **options )
		self.singleton_class.define_method( "call_#{name}_hook", &calling_body )
		self.singleton_method_alias( "run_#{name}_hook", "call_#{name}_hook" )
	end

end # module Mixins::Hooks


