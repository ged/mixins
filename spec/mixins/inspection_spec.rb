# -*- ruby -*-

require_relative '../spec_helper'

require 'mixins'


RSpec.describe( Mixins::Inspection ) do

	it "handles empty details" do
		oclass = Class.new do
			def initialize( serial )
				@serial = serial
			end
		end
		oclass.include( described_class )
		instance = oclass.new( 11 )

		expect( instance.inspect ).to match( /#<#{oclass.inspect}:0x\h+/ )
	end


	it "allows the inspection contents to be overridden" do
		oclass = Class.new do
			def initialize( serial )
				@serial = serial
			end
			attr_reader :serial
			def inspect_details
				return "serial: %d" % [ self.serial ]
			end
		end
		oclass.include( described_class )

		instance = oclass.new( 13 )

		expect( instance.inspect ).to match( /#<\S+ serial: 13>/ )
	end


	it "doesn't add a separator space if the details already being with a space" do
		oclass = Class.new do
			def initialize( serial )
				@serial = serial
			end
			attr_reader :serial
			def inspect_details
				return " serial: %d" % [ self.serial ]
			end
		end
		oclass.include( described_class )

		instance = oclass.new( 13 )

		expect( instance.inspect ).not_to match( /[ ]{2}/ )
	end

end

