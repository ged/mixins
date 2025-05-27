# -*- ruby -*-

require_relative '../spec_helper'

require 'mixins'


RSpec.describe( Mixins::Delegation ) do

	let( :testclass ) do
		Class.new do
			extend Mixins::Delegation

			@data_dir = nil
			class << self
				attr_accessor :data_dir
			end

			def initialize( obj=nil )
				@obj = obj
			end

			def demand_loaded_object
				return @load_on_demand ||= @obj
			end
		end
	end

	let( :subobj ) { double( "delegate" ) }
	let( :obj ) { testclass.new(subobj) }


	describe "method delegation" do

		it "can be used to set up delegation through a method" do
			testclass.def_method_delegators( :demand_loaded_object, :delegated_method )

			expect( subobj ).to receive( :delegated_method )

			obj.delegated_method
		end


		it "passes any arguments through to the delegate object's method" do
			testclass.def_method_delegators( :demand_loaded_object, :delegated_method )

			expect( subobj ).to receive( :delegated_method ).with( :arg1, :arg2 )

			obj.delegated_method( :arg1, :arg2 )
		end


		it "allows delegation to the delegate object's method with a block" do
			testclass.def_method_delegators :demand_loaded_object, :delegated_method

			expect( subobj ).to receive( :delegated_method ).with( :arg1 ).
				and_yield( :the_block_argument )

			blockarg = nil
			obj.delegated_method( :arg1 ) {|arg| blockarg = arg }

			expect( blockarg ).to eq( :the_block_argument )
		end


		it "reports errors from its caller's perspective", :ruby_1_8_only => true do
			testclass.def_method_delegators( :nonexistant_method, :erroring_delegated_method )

			begin
				obj.erroring_delegated_method
			rescue NoMethodError => err
				expect( err.message ).to match( /nonexistant_method/ )
				expect( err.backtrace.first ).to match( /#{__FILE__}/ )
			rescue ::Exception => err
				fail "Expected a NoMethodError, but got a %p (%s)" % [ err.class, err.message ]
			else
				fail "Expected a NoMethodError, but no exception was raised."
			end
		end


		it "delegates setters correctly" do
			testclass.def_method_delegators :demand_loaded_object, :delegated_setter=

			expect( subobj ).to receive( :delegated_setter= ).with( 1 )

			obj.delegated_setter = 1

			expect( subobj ).to receive( :delegated_setter= ).with( [1, 2] )

			obj.delegated_setter = 1, 2
		end

	end


	describe "instance variable delegation (ala Forwardable)" do

		let( :testclass ) do
			Class.new do
				extend Mixins::Delegation

				def initialize( obj )
					@obj = obj
				end
			end
		end


		it "can be used to set up delegation through a method" do
			testclass.def_ivar_delegators( :@obj, :delegated_method )

			expect( subobj ).to receive( :delegated_method )

			obj.delegated_method
		end


		it "passes any arguments through to the delegate's method" do
			testclass.def_ivar_delegators( :@obj, :delegated_method )

			expect( subobj ).to receive( :delegated_method ).with( :arg1, :arg2 )

			obj.delegated_method( :arg1, :arg2 )
		end


		it "allows delegation to the delegate's method with a block" do
			testclass.def_ivar_delegators( :@obj, :delegated_method )

			expect( subobj ).to receive( :delegated_method ).with( :arg1 ).
				and_yield( :the_block_argument )

			blockarg = nil
			obj.delegated_method( :arg1 ) {|arg| blockarg = arg }

			expect( blockarg ).to eq( :the_block_argument )
		end


		it "reports errors from its caller's perspective", :ruby_1_8_only => true do
			testclass.def_ivar_delegators( :@glong, :erroring_delegated_method )

			begin
				obj.erroring_delegated_method
			rescue NoMethodError => err
				expect( err.message ).to match( /['`]erroring_delegated_method' for nil/ )
				expect( err.backtrace.first ).to match( /#{__FILE__}/ )
			rescue ::Exception => err
				fail "Expected a NoMethodError, but got a %p (%s)" % [ err.class, err.message ]
			else
				fail "Expected a NoMethodError, but no exception was raised."
			end
		end


		it "delegates setters correctly" do
			testclass.def_ivar_delegators( :@obj, :delegated_setter= )

			expect( subobj ).to receive( :delegated_setter= ).with( 1 )

			obj.delegated_setter = 1

			expect( subobj ).to receive( :delegated_setter= ).with( [1, 2] )

			obj.delegated_setter = 1, 2
		end

	end


	describe "class-method delegation" do

		it "can be used to set up delegation through a method" do
			testclass.def_class_delegators :data_dir

			testclass.data_dir = '/path/to/the/data'
			obj = testclass.new

			expect( obj.data_dir ).to eq( '/path/to/the/data' )
		end

	end

end

