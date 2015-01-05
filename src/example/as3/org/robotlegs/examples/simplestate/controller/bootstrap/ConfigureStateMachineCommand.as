package org.robotlegs.examples.simplestate.controller.bootstrap
{

	import robotlegs.bender.bundles.mvcs.Command;
	import robotlegs.bender.util.fsmInjector.impl.FSMInjector;
	import robotlegs.bender.util.statemachine.impl.StateEvent;
	import robotlegs.bender.util.statemachine.impl.StateMachine;
	
	public class ConfigureStateMachineCommand extends Command
	{
		override public function execute():void
		{
			var smInjector:FSMInjector = new FSMInjector( StateMachineBootstrapConstants.FSM );
			var sm:StateMachine = new StateMachine(eventDispatcher);
			
			commandMap.mapEvent( StateMachineBootstrapConstants.CHECK_STORED_CREDENTIALS, CheckExistingCredentialsCommand );
			commandMap.mapEvent( StateMachineBootstrapConstants.LOGIN, LoginCommand );
			commandMap.mapEvent( StateMachineBootstrapConstants.RETRY_LOGIN, RetryLoginCommand );
			commandMap.mapEvent( StateMachineBootstrapConstants.DISPLAY_APPLICATION );
			commandMap.mapEvent( StateMachineBootstrapConstants.FAIL, BoostrapFailCommand );
			
			smInjector.inject( sm );
			
			eventDispatcher.dispatchEvent( new StateEvent( StateEvent.ACTION, StateMachineBootstrapConstants.STARTED );
		}
	}
}