/*
  ADAPTED FOR ROBOTLEGS FROM:
  PureMVC AS3 Utility - StateMachine
  Copyright (c) 2008 Neil Manuell, Cliff Hall
  Your reuse is governed by the Creative Commons Attribution 3.0 License
 */
package org.robotlegs.utilities.statemachine
{
	import flash.events.IEventDispatcher;
	

	public class FSMInjector implements IFSMInjector
	{
		[Inject(name='mvcsEventDispatcher')]
		public var eventDispatcher:IEventDispatcher;

		public function FSMInjector( fsm:XML )
		{
			_fsm = fsm;
		}
		
		/**
		 * Inject the <code>StateMachine</code> into the Robotlegs apparatus.
		 * <P>
		 * Creates the <code>StateMachine</code> instance, registers all the states
		 */
		public function inject(stateMachine:StateMachine):void
		{
			// Register all the states with the StateMachine
			for each ( var state:State in states )
			{ 
				stateMachine.registerState( state, isInitial( state.name ) );
			}				
			
			// Register the StateMachine with the facade
			stateMachine.onRegister();
		}

		
		/**
		 * Get the state definitions.
		 * <P>
		 * Creates and returns the array of State objects 
		 * from the FSM on first call, subsequently returns
		 * the existing array.</P>
		 */
		protected function get states():Array
		{
			if (!_stateList)
			{
				_stateList = [];
				
				var stateDefs:XMLList = _fsm..state;
				for (var i:int; i<stateDefs.length(); i++)
				{
					var stateDef:XML = stateDefs[i];
					var state:State = createState( stateDef );
					_stateList.push(state);
				}
			} 
			return _stateList;
		}

		/**
		 * Creates a <code>State</code> instance from its XML definition.
 		 */
		protected function createState( stateDef:XML ):State
		{
			// Create State object
			var name:String = stateDef.@name.toString();
			var exiting:String = stateDef.@exiting.toString();
			var entering:String = stateDef.@entering.toString();
			var changed:String = stateDef.@changed.toString();
			var state:State = new State( name, entering, exiting, changed );
			
			// Create transitions
			var transitions:XMLList = stateDef..transition as XMLList;
			for (var i:int; i<transitions.length(); i++)
			{
				var transDef:XML = transitions[i];
				state.defineTrans( String(transDef.@action), String(transDef.@target) );
			}
			return state;
		}

		/**
		 * Is the given state the initial state?
		 */
		protected function isInitial( stateName:String ):Boolean
		{
			var initial:String = XML(_fsm.@initial).toString();
			return (stateName == initial);
		}
		
		// The XML FSM definition
		protected var _fsm:XML;
		
		// The List of State objects
		protected var _stateList:Array;
		
		
		/**
		 * XML
		 * allow to completely change the FSM
		 */
		public function set xml(value:XML):void
		{
			dispose();
			
			_fsm = value;
		}
		public function get xml():XML
		{
			return _fsm;
		}
		
		
		/**
		 * dispose
		 */
		public function dispose():void
		{
			_fsm = null;
			_stateList = null;
		}
	}
}