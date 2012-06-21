package org.robotlegs.utilities.statemachine
{
	/**
	 * @author Benoit vinay - ben@benoitvinay.com
	 */
	public interface IFSMInjector
	{
		function inject(stateMachine:StateMachine):void;
	}
}