# -*- ruby -*-

require_relative '../spec_helper'

require 'mixins'


RSpec.describe( Mixins::Delegation ) do

	describe "method delegation" do

		before( :all ) do
			@testclass = Class.new do
				extend Mixins::Delegation

				def initialize( obj )
					@obj = obj
				end

				def_method_delegators :demand_loaded_object, :delegated_method
				def_method_delegators :nonexistant_method, :erroring_delegated_method

				def demand_loaded_object
					return @obj
				end
			end
		end

		before( :each ) do
			@subobj = double( "delegate" )
			@obj = @testclass.new( @subobj )
		end


		it "can be used to set up delegation through a method" do
			expect( @subobj ).to receive( :delegated_method )
			@obj.delegated_method
		end


		it "passes any arguments through to the delegate object's method" do
			expect( @subobj ).to receive( :delegated_method ).with( :arg1, :arg2 )
			@obj.delegated_method( :arg1, :arg2 )
		end


		it "allows delegation to the delegate object's method with a block" do
			expect( @subobj ).to receive( :delegated_method ).with( :arg1 ).
				and_yield( :the_block_argument )
			blockarg = nil
			@obj.delegated_method( :arg1 ) {|arg| blockarg = arg }
			expect( blockarg ).to eq( :the_block_argument )
		end


		it "reports errors from its caller's perspective", :ruby_1_8_only => true do
			begin
				@obj.erroring_delegated_method
			rescue NoMethodError => err
				expect( err.message ).to match( /nonexistant_method/ )
				expect( err.backtrace.first ).to match( /#{__FILE__}/ )
			rescue ::Exception => err
				fail "Expected a NoMethodError, but got a %p (%s)" % [ err.class, err.message ]
			else
				fail "Expected a NoMethodError, but no exception was raised."
			end
		end

	end


	describe "instance variable delegation (ala Forwardable)" do

		before( :all ) do
			@testclass = Class.new do
				extend Mixins::Delegation

				def initialize( obj )
					@obj = obj
				end

				def_ivar_delegators :@obj, :delegated_method
				def_ivar_delegators :@glong, :erroring_delegated_method

			end
		end

		before( :each ) do
			@subobj = double( "delegate" )
			@obj = @testclass.new( @subobj )
		end


		it "can be used to set up delegation through a method" do
			expect( @subobj ).to receive( :delegated_method )
			@obj.delegated_method
		end


		it "passes any arguments through to the delegate's method" do
			expect( @subobj ).to receive( :delegated_method ).with( :arg1, :arg2 )
			@obj.delegated_method( :arg1, :arg2 )
		end


		it "allows delegation to the delegate's method with a block" do
			expect( @subobj ).to receive( :delegated_method ).with( :arg1 ).
				and_yield( :the_block_argument )
			blockarg = nil
			@obj.delegated_method( :arg1 ) {|arg| blockarg = arg }
			expect( blockarg ).to eq( :the_block_argument )
		end


		it "reports errors from its caller's perspective", :ruby_1_8_only => true do
			begin
				@obj.erroring_delegated_method
			rescue NoMethodError => err
				expect( err.message ).to match( /`erroring_delegated_method' for nil/ )
				expect( err.backtrace.first ).to match( /#{__FILE__}/ )
			rescue ::Exception => err
				fail "Expected a NoMethodError, but got a %p (%s)" % [ err.class, err.message ]
			else
				fail "Expected a NoMethodError, but no exception was raised."
			end
		end

	end

end

