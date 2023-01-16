# -*- ruby -*-

require_relative 'spec_helper'

require 'rspec'
require 'mixins'

RSpec.describe( Mixins ) do

	SEMVER_PATTERN = %r{
		\A
		\d+(?:\.\d+){2}    # version; x.y.z
		(?:                # optional prerelease version
			-
			(?:[\w\-]+)
			(?:\.[\w\-]+)
		)?
		(?:                # optional build netadata
			\+
			(?:[\w\-]+)
			(?:\.[\w\-]+)
		)?
	}x


	it "has a semantic version in its VERSION constant" do
		expect( described_class::VERSION ).to be_a( String )
		expect( described_class::VERSION ).to match( SEMVER_PATTERN )
	end

end

