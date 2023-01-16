# -*- ruby -*-

require 'mixins' unless defined?( Mixins )


# An extensible #inspect.
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

