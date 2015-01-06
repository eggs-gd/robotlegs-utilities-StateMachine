/*
 ADAPTED FOR ROBOTLEGS FROM:
 PureMVC AS3 Utility - StateMachine
 Copyright (c) 2008 Neil Manuell, Cliff Hall
 Your reuse is governed by the Creative Commons Attribution 3.0 License
 */
package robotlegs.bender.util.statemachine.impl {
    import flash.events.IEventDispatcher;

    import robotlegs.bender.util.statemachine.api.IState;

    import robotlegs.bender.util.statemachine.api.IStateMachine;


    public class StateMachine implements IStateMachine {

        //=====================================================================
        //region  History
        //=====================================================================
        protected var _history:Vector.<String>;
        public function get history():Vector.<String> { return _history; }
        public function getHistory(offset:int):String {
            return _history[_history.length - 1 - Math.abs(offset)];
        }
        //endregion ===========================================================

        //=====================================================================
        //region  States
        //=====================================================================
        protected var _previousState:IState;
        public function get previousState():IState { return _previousState; }

        protected var _currentState:IState;
        public function get currentState():IState { return _currentState; }
        public function get currentStateName():String { return _currentState.name; }
        //endregion ===========================================================

        protected var _eventDispatcher:IEventDispatcher;

        /**
         * Map of States objects by name.
         */
        protected var _states:Object = {};

        /**
         * The initial state of the FSM.
         */
        protected var _initial:IState;

        /**
         * The transition has been canceled.
         */
        protected var _canceled:Boolean;

        protected var _hasChanged:Boolean = false;
        protected var _actionQueue:Array;

        /**
         *  robotlegs.bender.util.statemachine.impl.StateMachine Constructor
         * @param eventDispatcher an event dispatcher used to communicate with interested actors.
         * This is typically the Robotlegs framework.
         *
         */
        public function StateMachine(eventDispatcher:IEventDispatcher) {
            _eventDispatcher = eventDispatcher;
            _history = new <String>[];
        }

        public function onRegister():void {
            _eventDispatcher.addEventListener(StateEvent.ACTION, handleStateAction);
            _eventDispatcher.addEventListener(StateEvent.CANCEL, handleStateCancel);
            if (_initial) {
                transitionTo(_initial, null);
            }
        }

        public function onRemove():void {
            _eventDispatcher.removeEventListener(StateEvent.ACTION, handleStateAction);
            _eventDispatcher.removeEventListener(StateEvent.CANCEL, handleStateCancel);
        }

        protected function handleStateAction(event:StateEvent):void {
            // if current state hasn't finished transitioning
            if (!_hasChanged) {
                // add it to the queue
                if (!_actionQueue) {
                    _actionQueue = [];
                }
                _actionQueue.push(event);
                return;
            }

            // can't call twice the same action for state
            var nextState:IState = getStateForAction(event.action);
            if (_currentState && nextState && _currentState.name == nextState.name) {
                return;
            }

            // transition
            var newStateTarget:String = _currentState.getTarget(event.action);
            var newState:State = _states[newStateTarget];
            if (newState) {
                transitionTo(newState, event.data);
            }
        }

        protected function handleStateCancel(event:StateEvent):void {
            _canceled = true;
        }

        /**
         * Registers the entry and exit commands for a given state.
         *
         * @param state the state to which to register the above commands
         * @param initial boolean telling if this is the initial state of the system
         */
        public function registerState(state:IState, initial:Boolean = false):void {
            if (state == null || _states[state.name] != null) {
                return;
            }

            _states[state.name] = state;
            if (initial) {
                _initial = state;
            }
        }

        /**
         * Retrieve a state.
         * <P>
         * Utility method for retrieving a State.</P>
         *
         * @param stateName
         */
        public function getStateByName(stateName:String):IState {
            return _states[stateName];
        }

        public function getStateForAction(action:String):IState {
            return _currentState ? _states[_currentState.getTarget(action)] : null;
        }

        /**
         * Remove a state mapping.
         * <P>
         * Removes the entry and exit commands for a given state
         * as well as the state mapping itself.</P>
         *
         * @param stateName
         */
        public function removeState(stateName:String):void {
            var state:IState = _states[stateName];
            if (state == null) {
                return;
            }

            _states[stateName] = null;
        }

        /**
         * Transitions to the given state from the current state.
         * <P>
         * Sends the <code>exiting</code> StateEvent for the current state
         * followed by the <code>entering</code> StateEvent for the new state.
         * Once finally transitioned to the new state, the <code>changed</code>
         * StateEvent for the new state is sent.</P>
         * <P>
         * If a data parameter is provided, it is included as the body of all
         * three state-specific transition notes.</P>
         * <P>
         * Finally, when all the state-specific transition notes have been
         * sent, a <code>StateEvent.CHANGED</code> event is sent, with the
         * new <code>State</code> object as the <code>body</code> and the name of the
         * new state in the <code>type</code>.
         *
         * @param nextState the next State to transition to.
         * @param data is the optional Object that was sent in the <code>StateEvent.ACTION</code> event
         */
        protected function transitionTo(nextState:IState, data:Object = null):void {
            _hasChanged = false;

            if (_currentState) {
                _previousState = _states[currentStateName];
                _history.push(_previousState.name);
            }

            // Going nowhere?
            if (nextState == null) {
                return;
            }

            // Clear the cancel flag
            _canceled = false;

            // Exit the current State
            if (_currentState && _currentState.exiting) {
                _eventDispatcher.dispatchEvent(new StateEvent(_currentState.exiting, null, data));
            }

            // Check to see whether the exiting guard has been canceled
            if (_canceled) {
                _canceled = false;
                return;
            }

            // Enter the next State
            if (nextState.entering) {
                _eventDispatcher.dispatchEvent(new StateEvent(nextState.entering, null, data));
            }

            // Check to see whether the entering guard has been canceled
            if (_canceled) {
                _canceled = false;
                return;
            }

            // change the current state only when both guards have been passed
            _currentState = nextState;

            // Send the notification configured to be sent when this specific state becomes current
            if (nextState.changed) {
                _eventDispatcher.dispatchEvent(new StateEvent(_currentState.changed, null, data));
            }

            // Notify the app generally that the state changed and what the new state is
            _eventDispatcher.dispatchEvent(new StateEvent(StateEvent.CHANGED, _currentState.name));

            // to be able to listen to the state itself
            _eventDispatcher.dispatchEvent(new StateEvent(_currentState.name));

            // changed
            _hasChanged = true;

            // queue
            transitionToQueueState();
        }

        /**
         * Transitions queue.
         * <P>
         * Used to be sure to transition to next state after all observers have been notified of the previous state.</P>
         * <P>
         * To be sure the app has completely transition to a State.</P>
         */
        protected function transitionToQueueState():void {
            // if queue
            if (_actionQueue && _actionQueue.length > 0) {
                var stateEvent:StateEvent = _actionQueue.shift();

                // if currentState has no state for that action
                // we go to the next one
                if (!_currentState.getTarget(stateEvent.action)) {
                    transitionToQueueState();
                }
                else {
                    handleStateAction(stateEvent);
                }
            }
        }


        /**
         * dispose
         */
        public function dispose():void {
            onRemove();

            _eventDispatcher = null;
            _initial = null;
            _previousState = null;
            _currentState = null;

            _states = null;
            _actionQueue = null;
            _history = null;
        }


        /**
         * Utils
         */
        public function toString():String {
            return "StateMachine (current State: " + _currentState.name + ")";
        }
    }
}