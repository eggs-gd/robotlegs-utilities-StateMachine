package org.robotlegs.utilities.statemachine
{
	/**
	 * @author Benoit vinay - ben@benoitvinay.com
	 */
	public interface IStateMachine
	{
		function onRegister():void;
		
		function registerState( state:State, initial:Boolean=false ):void;
		function removeState( stateName:String ):void;
		
		function get currentState():State;
		function get currentStateName():String;
	}
}