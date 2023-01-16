# -*- ruby -*-

require_relative '../spec_helper'

require 'mixins'


RSpec.describe( Mixins::Datadir ) do

	let( :zebra_gemspec ) do
		Gem::Specification.new do |s|
			s.name = "zebra"
			s.version = Gem::Version.new("0.2.1")
			s.installed_by_version = Gem::Version.new("0")
			s.authors = ["Zaphod Beeblebrox"]
			s.date = Time.utc(2024, 6, 12)
			s.description = "So many zebras."
			s.email = ["zaph@example.com"]
			s.files = ["zebras.rb"]
			s.homepage = "https://github.com/zaph/zebras"
			s.licenses = ["Ruby", "BSD-2-Clause"]
			s.metadata = {
				"homepage_uri"=>"https://github.com/zaph/zebras",
				"source_code_uri"=>"https://github.com/zaph/zebras"
			}
			s.require_paths = ["lib"]
			s.required_ruby_version = Gem::Requirement.new([">= 2.5.0"])
			s.rubygems_version = "3.5.11"
			s.specification_version = 4
			s.summary = "All the zebras."
		end
	end
	let( :zebra_datadir ) { '/path/to/installed/gem/datadir' }
	let( :loaded_gemspecs ) { { 'zebra' => zebra_gemspec } }


	before( :each ) do
		@original_env = ENV.to_h
	end
	after( :each ) do
		ENV.replace( @original_env )
	end


	it "uses the currently-loaded gem's data directory if there is one" do
		expect( Gem ).to receive( :loaded_specs ).
			and_return( loaded_gemspecs ).at_least( :once )
		expect( zebra_gemspec ).to receive( :datadir ).
			and_return( zebra_datadir ).at_least( :once )
		expect( File ).to receive( :exist? ).with( zebra_datadir ).and_return( true )

		target_class = Class.new do
			def self::name; 'Zebra'; end
		end
		target_class.extend( described_class )

		expect( target_class.data_dir ).to eq( Pathname(zebra_datadir) )
	end


	it "uses the directory at ../../data/<gemname> if no gem is loaded" do
		target_class = Class.new do
			def self::name; 'Panda'; end
		end
		target_class.extend( described_class )

		local_datadir = Pathname( __FILE__ ).parent.parent.parent / 'data' / 'panda'

		expect( target_class.data_dir ).to eq( local_datadir )
	end


	it "allows the data dir to be overridden using an environment variable" do
		ocelot_data = '/path/to/ocelot/data'
		ENV['OCELOT_DATADIR'] = ocelot_data

		target_class = Class.new do
			def self::name; 'Ocelot'; end
		end
		target_class.extend( described_class )

		expect( target_class.data_dir ).to eq( Pathname(ocelot_data) )
	end

end

