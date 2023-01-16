# -*- ruby -*-

require_relative '../spec_helper'

require 'mixins'


RSpec.describe( Mixins::DataUtilities ) do

	it "doesn't try to dup immediate objects" do
		expect( Mixins::DataUtilities.deep_copy( nil ) ).to be( nil )
		expect( Mixins::DataUtilities.deep_copy( 112 ) ).to be( 112 )
		expect( Mixins::DataUtilities.deep_copy( true ) ).to be( true )
		expect( Mixins::DataUtilities.deep_copy( false ) ).to be( false )
		expect( Mixins::DataUtilities.deep_copy( :a_symbol ) ).to be( :a_symbol )
	end


	it "doesn't try to dup modules/classes" do
		klass = Class.new
		expect( Mixins::DataUtilities.deep_copy( klass ) ).to be( klass )
	end


	it "doesn't try to dup IOs" do
		data = [ $stdin ]
		expect( Mixins::DataUtilities.deep_copy( data[0] ) ).to be( $stdin )
	end


	it "doesn't try to dup Tempfiles" do
		data = Tempfile.new( 'ravn_deepcopy.XXXXX' )
		expect( Mixins::DataUtilities.deep_copy( data ) ).to be( data )
	end


	it "makes distinct copies of arrays and their members" do
		original = [ 'foom', Set.new([ 1,2 ]), :a_symbol ]

		copy = Mixins::DataUtilities.deep_copy( original )

		expect( copy ).to eq( original )
		expect( copy ).to_not be( original )
		expect( copy[0] ).to eq( original[0] )
		expect( copy[0] ).to_not be( original[0] )
		expect( copy[1] ).to eq( original[1] )
		expect( copy[1] ).to_not be( original[1] )
		expect( copy[2] ).to eq( original[2] )
		expect( copy[2] ).to be( original[2] ) # Immediate
	end


	it "makes recursive copies of deeply-nested Arrays" do
		original = [ 1, [ 2, 3, [4], 5], 6, [7, [8, 9], 0] ]

		copy = Mixins::DataUtilities.deep_copy( original )

		expect( copy ).to eq( original )
		expect( copy ).to_not be( original )
		expect( copy[1] ).to_not be( original[1] )
		expect( copy[1][2] ).to_not be( original[1][2] )
		expect( copy[3] ).to_not be( original[3] )
		expect( copy[3][1] ).to_not be( original[3][1] )
	end


	it "makes distinct copies of Hashes and their members" do
		original = {
			:a => 1,
			'b' => 2,
			3 => 'c',
		}

		copy = Mixins::DataUtilities.deep_copy( original )

		expect( copy ).to eq( original )
		expect( copy ).to_not be( original )
		expect( copy[:a] ).to eq( 1 )
		expect( copy.key( 2 ) ).to eq( 'b' )
		expect( copy.key( 2 ) ).to_not be( original.key(2) )
		expect( copy[3] ).to eq( 'c' )
		expect( copy[3] ).to_not be( original[3] )
	end


	it "makes distinct copies of deeply-nested Hashes" do
		original = {
			:a => {
				:b => {
					:c => 'd',
					:e => 'f',
				},
				:g => 'h',
			},
			:i => 'j',
		}

		copy = Mixins::DataUtilities.deep_copy( original )

		expect( copy ).to eq( original )
		expect( copy[:a][:b][:c] ).to eq( 'd' )
		expect( copy[:a][:b][:c] ).to_not be( original[:a][:b][:c] )
		expect( copy[:a][:b][:e] ).to eq( 'f' )
		expect( copy[:a][:b][:e] ).to_not be( original[:a][:b][:e] )
		expect( copy[:a][:g] ).to eq( 'h' )
		expect( copy[:a][:g] ).to_not be( original[:a][:g] )
		expect( copy[:i] ).to eq( 'j' )
		expect( copy[:i] ).to_not be( original[:i] )
	end


	it "copies the default proc of copied Hashes" do
		original = Hash.new {|h,k| h[ k ] = Set.new }

		copy = Mixins::DataUtilities.deep_copy( original )

		expect( copy.default_proc ).to eq( original.default_proc )
	end


	it "preserves frozen-ness of copied objects" do
		original = Object.new
		original.freeze

		copy = Mixins::DataUtilities.deep_copy( original )

		expect( copy ).to_not be( original )
		expect( copy ).to be_frozen()
	end


	it "can recursively transform Hash keys into Symbols" do
		original = {
			'id' => 'a8fd4d6f-5c0f-45b2-8732-8b8a90b595de',
			'time' => Time.now.to_f,
			'type' => 'sparrow.order.turning',
			'data' => {
				'response_type' => 'receipt',
				'response' => 1
			}
		}

		result = Mixins::DataUtilities.symbolify_keys( original )

		expect( result.keys ).to all( be_a Symbol )
		expect( result[:data].keys ).to all( be_a Symbol )
	end


	it "doesn't try to turn keys other than Strings into Symbols" do
		original = {
			'foo' => {
				'bar' => 3,
				3 => 'bar',
			}
		}

		result = Mixins::DataUtilities.symbolify_keys( original )

		expect( result[:foo].keys ).to contain_exactly( :bar, 3 )
	end


	it "doesn't try to turn String keys that aren't identifiers into Symbols" do
		original = {
			'foo' => {
				'an arbitrary string' => 3,
				'$punctuation_string' => 8,
				'_underscore_string'  => 4,
			}
		}

		result = Mixins::DataUtilities.symbolify_keys( original )

		expect( result[:foo].keys ).
			to contain_exactly( 'an arbitrary string', '$punctuation_string', :_underscore_string )
	end


	it "recurses into Arrays when transforming Hash keys into Symbols" do
		original = {
			'type' => 'Vic Checkin',
			'text' => 'Vehicles check in',
			'ontological_suffix' => 'conversation.headcount',
			'components' => {
				'recipients' => {
					'to' => 'Vic Commanders',
				},
				'responses' => {
					'responses_from' => 'Vic Commanders',
					'send_label' => 'Send UP',
					'steps' => [
						{ 'type' => 'integer', 'label' => 'PAX' },
						{ 'type' => 'select', 'label' => 'Ready', 'values' => ['yes', 'no'] },
					],
				}
			}
		}

		result = Mixins::DataUtilities.symbolify_keys( original )

		expect( result.keys ).to all( be_a Symbol )
		expect( result.dig(:components, :responses, :steps) ).to all( include(:type, :label) )
	end


	it "can recursively transform Hash keys into Strings" do
		original = {
			:id => '4cc37025-fb34-47ef-b762-6abac23e0792',
			:time => Time.now.to_f,
			:type => 'acme.widget.model1',
			1 => 'something',
			:data => {
				:response_type => 'receipt',
				:response_id => 1
			}
		}

		result = Mixins::DataUtilities.stringify_keys( original )

		expect( result.keys ).to contain_exactly( 'id', 'time', 'type', 1, 'data' )
		expect( result['data'].keys ).to contain_exactly( 'response_type', 'response_id' )
	end


	it "doesn't stringify non-Symbols when stringifying Hash keys" do
		original = {
			:foo => "bar",
			18 => "something",
		}

		result = Mixins::DataUtilities.stringify_keys( original )

		expect( result.keys ).to contain_exactly( 'foo', 18 )
	end


	it "recurses into Arrays when transforming Hash keys into Strings" do
		original = {
			type: 'Teddy Bear',
			text: "What's your name?",
			sort: 'toy.plush.animal',
			components: {
				route: {
					to: 'receiving@acme.com',
				},
				responses: {
					responses_from: 'warehouse1@acme.com',
					send_label: 'BZ5556',
					steps: [
						{ type: 'integer', label: 'QC' },
						{ type: 'select', label: 'conv1', values: ['yes', 'no'] },
					],
				}
			}
		}

		result = Mixins::DataUtilities.stringify_keys( original )

		expect( result.keys ).to all( be_a String )
		expect( result.dig('components', 'responses', 'steps') ).to all( include('type', 'label') )
	end

end


