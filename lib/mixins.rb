# -*- ruby -*-


# A collection of Modules that can be mixed into other modules to make
# common tasks easier and more intention-revealing.
module Mixins

	# Package version
	VERSION = '0.0.1'


	autoload :MethodUtilities, 'mixins/method_utilities'
	autoload :DataUtilities, 'mixins/data_utilities'
	autoload :Delegation, 'mixins/delegation'
	autoload :Hooks, 'mixins/hooks'
	autoload :Inspection, 'mixins/inspection'
	autoload :Datadir, 'mixins/datadir'

end # module Mixins

