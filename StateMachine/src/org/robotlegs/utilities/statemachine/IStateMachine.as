package org.robotlegs.utilities.statemachine
{
	/**
	 * @author Benoit vinay - ben@benoitvinay.com
	 */
	public interface IStateMachine
	{
		function onRegister():void;
		function onRemove():void;
		
		function retrieveState(stateName:String):State;
		function registerState(state:State, initial:Boolean = false):void;
		function removeState(stateName:String):void;
		
		function get previousState():State
		function get currentState():State
		function get currentStateName():String;
		
		function get history():Array;
		function getHistory(offset:int):String;
		
		function getStateForAction(action:String):State;
		function getActionForState(state:String, separator:String = "/"):String;
	}
}