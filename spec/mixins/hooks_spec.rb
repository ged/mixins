# -*- ruby -*-

require_relative '../spec_helper'

require 'mixins'


RSpec.describe( Mixins::Hooks ) do

	let( :extended_object ) do
		obj = Object.new
		obj.extend( described_class )
		return obj
	end


	it "allows a set of hooks to be declared" do
		extended_object.define_hook( :after_fork )

		hook1_called = false
		hook2_called = false

		extended_object.after_fork do
			hook1_called = true
		end
		extended_object.after_fork do
			hook2_called = true
		end

		expect {
			extended_object.call_after_fork_hook
		}.to change { hook1_called }.to( true ).and \
			change { hook2_called }.to( true ).and \
			change { extended_object.after_fork_callbacks_run? }.to( true )
	end


	it "ensures declared hooks are run at least once" do
		extended_object.define_hook( :after_fork )

		hook1_called = false
		hook2_called = false

		extended_object.after_fork do
			hook1_called = true
		end
		extended_object.call_after_fork_hook
		extended_object.after_fork do
			hook2_called = true
		end

		expect( hook1_called ).to be_truthy
		expect( hook2_called ).to be_truthy
	end


	it "doesn't re-register a hook callback that already exists" do
		extended_object.define_hook( :before_fork )

		callback = Proc.new {}
		extended_object.before_fork( &callback )
		extended_object.before_fork( &callback )

		expect( extended_object.before_fork_callbacks.length ).to eq( 1 )
	end


	it "can declare a hook that passes arguments to its callbacks" do
		extended_object.define_hook( :on_event )

		callback_args = []
		extended_object.on_event do |ev, *args|
			callback_args << [ev, args]
		end

		extended_object.call_on_event_hook( :slip, 4 )
		extended_object.call_on_event_hook( :traverse, 16 )

		expect( callback_args ).to contain_exactly(
			[:slip, [4]],
			[:traverse, [16]]
		)
	end

end

