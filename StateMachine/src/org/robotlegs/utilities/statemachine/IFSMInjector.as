package org.robotlegs.utilities.statemachine
{
	/**
	 * @author Benoit vinay - ben@benoitvinay.com
	 */
	public interface IFSMInjector
	{
		function inject(stateMachine:StateMachine):void;
		
		function set xml(value:XML):void;
		function get xml():XML;
		
		function reset():void;
	}
}