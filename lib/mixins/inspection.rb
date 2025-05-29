# -*- ruby -*-

require 'mixins' unless defined?( Mixins )


# An extensible #inspect.
#
# This adds an overloaded #inspect method to including classes that provides
# a way to easily extend the default #inspect output. To add your own output to
# the body of the inspected object, implement the #inspect_details method and
# return your desired output from it. By default it returns the empty string, which
# will cause #inspect to use the default output.
module Mixins::Inspection

	### Return a human-readable representation of the object suitable for debugging.
	def inspect
		details = self.inspect_details
		details = ' ' + details unless details.empty? || details.start_with?( ' ' )

		return "#<%p:#%x%s>" % [
			self.class,
			self.object_id,
			details,
		]
	end


	### Return the detail portion of the inspect output for this object.
	def inspect_details
		return ''
	end

end # module Mixins::Inspection

