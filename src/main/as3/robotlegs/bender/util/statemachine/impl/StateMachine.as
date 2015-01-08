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
    import robotlegs.bender.util.statemachine.api.ITransition;


    public class StateMachine implements IStateMachine {

        private static const INITIAL_TRANSITION_NAME:String = "robotlegs.bender.util.statemachine.impl.StateMachine.INITIAL_TRANSITION_NAME";

        //=====================================================================
        //  History
        //=====================================================================
        /** @inheritDoc */
        public function get history():Vector.<String> { return _history; }
        private var _history:Vector.<String>;

        /** @inheritDoc */
        public function get currentState():IState { return _currentState; }
        private var _currentState:IState;

        /** @inheritDoc */
        public function get pendingState():IState { return _pendingState; }
        private var _pendingState:IState;

        /** @inheritDoc */
        public function get isInTransition():Boolean { return Boolean(pendingState); }

        //=====================================================================
        //  Private
        //=====================================================================
        private var _eventDispatcher:IEventDispatcher;

        /** Map of States objects by name. */
        private var _states:Vector.<IState>;

        /** The initial state of the FSM. */
        private var _initialTransition:ITransition;

        private var _actionQueue:Vector.<StateEvent>;

        /**
         *  robotlegs.bender.util.statemachine.impl.StateMachine Constructor
         * @param eventDispatcher an event dispatcher used to communicate with interested actors.
         * This is typically the Robotlegs framework.
         */
        public function StateMachine(eventDispatcher:IEventDispatcher) {
            _eventDispatcher = eventDispatcher;
            _history = new <String>[];
            _states = new <IState>[];
            _actionQueue = new <StateEvent>[];
        }

        public function toString():String {
            return "StateMachine (current State: " + currentState.name + ")";
        }

        /** @inheritDoc */
        public function onRegister():void {
            _eventDispatcher.addEventListener(StateEvent.ACTION, handleStateAction);
            _eventDispatcher.addEventListener(StateEvent.CLOSE, handleStateCancel);
            if (_initialTransition) {
                _pendingState = getStateByName(_initialTransition.target);
                completeState();
            }
        }

        /** @inheritDoc */
        public function onRemove():void {
            _eventDispatcher.removeEventListener(StateEvent.ACTION, handleStateAction);
            _eventDispatcher.removeEventListener(StateEvent.CLOSE, handleStateCancel);
        }

        /** @inheritDoc */
        public function dispose():void {
            onRemove();

            _eventDispatcher = null;
            _initialTransition = null;

            _states = null;
            _actionQueue = null;
            _history = null;
        }

        /** @inheritDoc */
        public function registerState(state:IState, initial:Boolean = false):Boolean {
            if (!state || hasRegistered(state.name)) {
                return false;
            }

            _states.push(state);
            if (initial) {
                _initialTransition = new Transition(INITIAL_TRANSITION_NAME, state.name);
            }

            return true;
        }

        /** @inheritDoc */
        public function getStateByName(stateName:String):IState {
            for each(var state:IState in _states) {
                if (state.name == stateName) {
                    return state;
                }
            }
            return null;
        }

        /** @inheritDoc */
        public function hasRegistered(stateName:String):Boolean {
            return Boolean(getStateByName(stateName));
        }

        /** @inheritDoc */
        public function getStateByAction(action:String):IState {
            if (currentState) {
                var transition:ITransition = currentState.getTransition(action);
                if (transition) {
                    return getStateByName(transition.target);
                }
            }

            return null;
        }

        /** @inheritDoc */
        public function removeState(stateName:String):Boolean {
            var state:IState = getStateByName(stateName);
            if (state == null) {
                return false;
            }

            _states.splice(_states.indexOf(state), 1);
            return true;
        }

        /**
         * Transitions queue.
         * <P>
         * Used to be sure to transition to next state after all observers have been notified of the previous state.</P>
         * <P>
         * To be sure the app has completely transition to a State.</P>
         */
        private function transitionToQueueState():void {
            // if queue
            if (_actionQueue && _actionQueue.length > 0) {
                var stateEvent:StateEvent = _actionQueue.shift();

                // if currentState has no state for that action
                // we go to the next one
                if (!_currentState.getTransition(stateEvent.action)) {
                    transitionToQueueState();
                } else {
                    handleStateAction(stateEvent);
                }
            }
        }

        /**
         * Start transition to state
         * @param action
         * @param data
         * @return true if started
         */
        private function startState(action:String, data:Object = null):Boolean {
            // can't call twice the same action for state
            if (!canDoTransition(action)) {
                return false;
            }

            _pendingState = getStateByAction(action);
            _history.push(currentState.name);

            if (currentState.exiting) {
                _eventDispatcher.dispatchEvent(new StateEvent(currentState.exiting, currentState.name, data));
            }

            if (pendingState.entering) {
                _eventDispatcher.dispatchEvent(new StateEvent(pendingState.entering, currentState.name, data));
            }

            var transition:ITransition = currentState.getTransition(action);
            _currentState = null;

            if (transition.complete != "") { // if transition is instant
                _eventDispatcher.addEventListener(TransitionEvent.COMPLETE, onTransitionComplete);
                _eventDispatcher.addEventListener(TransitionEvent.CANCEL, onTransitionCancel);
            } else {
                completeState(data);
            }
            return true;
        }

        private function completeState(data:Object = null):void {
            _currentState = pendingState;

            if (pendingState.complete) {
                _eventDispatcher.dispatchEvent(new StateEvent(currentState.complete, currentState.name, data));
            }

            // Notify the app generally that the state changed and what the new state is
            _eventDispatcher.dispatchEvent(new StateEvent(StateEvent.COMPLETE, currentState.name, data));
            _pendingState = null;

            // queue
            transitionToQueueState();
        }

        private function closeState():void {
            //cancel previous
            if (pendingState && pendingState.exiting) {
                _eventDispatcher.dispatchEvent(new StateEvent(pendingState.exiting, pendingState.name));
            }
            _pendingState = getStateByName(history.pop());

            completeState();
        }

        private function addToQueue(event:StateEvent):void {
            _actionQueue.push(event);
        }

        private function canDoTransition(action:String):Boolean {
            if (!currentState && action == INITIAL_TRANSITION_NAME) {
                return true;
            }

            if (isInTransition) {
                return false;
            }

            var nextState:IState = getStateByAction(action);

            if (!nextState || !currentState) {
                return false;
            }
            if (currentState.name == nextState.name) {
                return false;
            }

            return currentState.hasTransition(action);
        }

        //=====================================================================
        //  Handlers
        //=====================================================================
        private function handleStateAction(event:StateEvent):void {
            if (isInTransition) {
                addToQueue(event);
                return;
            }

            startState(event.action, event.data);
        }

        private function handleStateCancel(event:StateEvent):void {
            closeState()
        }

        private function onTransitionComplete(event:TransitionEvent):void {
            completeState(event.data);
        }

        private function onTransitionCancel(event:TransitionEvent):void {
            closeState();
        }
    }
}