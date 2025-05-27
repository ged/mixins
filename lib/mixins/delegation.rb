# -*- ruby -*-

require 'mixins' unless defined?( Mixins )


# A collection of various delegation code-generators that can be used to define
# delegation through other methods, to instance variables, etc.
module Mixins::Delegation

	### Define the given +delegated_methods+ as delegators to the like-named method
	### of the return value of the +delegate_method+.
	###
	###    class MyClass
	###      extend Strelka::Delegation
	###
	###      # Delegate the #bound?, #err, and #result2error methods to the connection
	###      # object returned by the #connection method. This allows the connection
	###      # to still be loaded on demand/overridden/etc.
	###      def_method_delegators :connection, :bound?, :err, :result2error
	###
	###      def connection
	###        @connection ||= self.connect
	###      end
	###    end
	###
	def def_method_delegators( delegate_method, *delegated_methods )
		delegated_methods.each do |name|
			body = Mixins::Delegation.make_method_delegator( delegate_method, name )
			define_method( name, &body )
		end
	end


	### Define the given +delegated_methods+ as delegators to the like-named method
	### of the specified +ivar+. This is pretty much identical with how 'Forwardable'
	### from the stdlib does delegation, but it's reimplemented here for consistency.
	###
	###    class MyClass
	###      extend Strelka::Delegation
	###
	###      # Delegate the #each method to the @collection ivar
	###      def_ivar_delegators :@collection, :each
	###
	###    end
	###
	def def_ivar_delegators( ivar, *delegated_methods )
		delegated_methods.each do |name|
			body = Mixins::Delegation.make_ivar_delegator( ivar, name )
			define_method( name, &body )
		end
	end


	### Define the given +delegated_methods+ as delegators to the like-named class
	### method.
	def def_class_delegators( *delegated_methods )
		delegated_methods.each do |name|
			define_method( name ) do |*args|
				self.class.__send__( name, *args )
			end
		end
	end


	###############
	module_function
	###############

	### Make the body of a delegator method that will delegate to the +name+ method
	### of the object returned by the +delegate+ method.
	def make_method_delegator( delegate, name )
		return ->( *args, **kwargs, &block ) do
			self.__send__( delegate ).__send__( name, *args, **kwargs, &block )
		rescue => err
			bt = err.backtrace_locations
			bt.shift
			raise( err, err.message, bt, cause: err )
		end
	end


	### Make the body of a delegator method that will delegate calls to the +name+
	### method to the given +ivar+.
	def make_ivar_delegator( ivar_name, name )
		return ->( *args, **kwargs, &block ) do
			ivar = self.instance_variable_get( ivar_name )
			ivar.__send__( name, *args, **kwargs, &block )
		rescue => err
			bt = err.backtrace_locations
			bt.shift
			raise( err, err.message, bt, cause: err )
		end
	end

end # module Delegation
