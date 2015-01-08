/*
 ADAPTED FOR ROBOTLEGS FROM:
 PureMVC AS3 Utility - StateMachine
 Copyright (c) 2008 Neil Manuell, Cliff Hall
 Your reuse is governed by the Creative Commons Attribution 3.0 License
 */
package robotlegs.bender.util.statemachine.impl {
    import flash.errors.IllegalOperationError;
    import flash.events.IEventDispatcher;

    import robotlegs.bender.util.statemachine.api.IState;
    import robotlegs.bender.util.statemachine.api.IStateMachine;
    import robotlegs.bender.util.statemachine.api.ITransition;
    import robotlegs.bender.util.statemachine.impl.TransitionEvent;


    public class StateMachine implements IStateMachine {

        private static const INITIAL_TRANSITION_NAME:String = "robotlegs.bender.util.statemachine.impl.StateMachine.INITIAL_TRANSITION_NAME";

        //=====================================================================
        //  History
        //=====================================================================
        /** @inheritDoc */
        public function get history():Vector.<String> { return _history.concat(); }
        private var _history:Vector.<String>;

        /** @inheritDoc */
        public function get currentState():IState { return _currentState; }
        private var _currentState:IState;

        /** @inheritDoc */
        public function get pendingState():IState { return _pendingState; }
        private var _pendingState:IState;

        /** @inheritDoc */
        public function get currentTransition():ITransition { return _currentTransition; }
        private var _currentTransition:ITransition;

        //=====================================================================
        //  Private
        //=====================================================================
        private var _eventDispatcher:IEventDispatcher;

        /** Map of States objects by name. */
        private var _states:Vector.<IState>;
        private var _statesMap:Object; // {stateName:state}

        /** The initial state of the FSM. */
        private var _initialState:IState;

        /**
         *  robotlegs.bender.util.statemachine.impl.StateMachine Constructor
         * @param eventDispatcher an event dispatcher used to communicate with interested actors.
         * This is typically the Robotlegs framework.
         */
        public function StateMachine(eventDispatcher:IEventDispatcher) {
            _eventDispatcher = eventDispatcher;
            _history = new <String>[];
            _states = new <IState>[];
            _statesMap = {};
        }

        public function toString():String {
            return "StateMachine (current State: " + currentState.name + ")";
        }

        /** @inheritDoc */
        public function onRegister():void {
            _eventDispatcher.addEventListener(StateEvent.ACTION, handleStateAction);
            _eventDispatcher.addEventListener(StateEvent.BACK, handleStateBack);
            _eventDispatcher.addEventListener(StateEvent.COMPLETE, handleStateComplete);

            _eventDispatcher.addEventListener(TransitionEvent.COMPLETE, onTransitionComplete);
            _eventDispatcher.addEventListener(TransitionEvent.CANCEL, onTransitionCancel);

            if (_initialState) {
                _pendingState = _initialState;
                completeState();
            } else {
                throw new DefinitionError("Not registered initial state");
            }
        }

        /** @inheritDoc */
        public function onRemove():void {
            _eventDispatcher.removeEventListener(StateEvent.ACTION, handleStateAction);
            _eventDispatcher.removeEventListener(StateEvent.BACK, handleStateBack);
            _eventDispatcher.removeEventListener(StateEvent.COMPLETE, handleStateComplete);

            _eventDispatcher.removeEventListener(TransitionEvent.COMPLETE, onTransitionComplete);
            _eventDispatcher.removeEventListener(TransitionEvent.CANCEL, onTransitionCancel);
        }

        /** @inheritDoc */
        public function dispose():void {
            onRemove();

            _eventDispatcher = null;
            _initialState = null;

            _states = null;
            _statesMap = null;
            _history = null;
        }

        /** @inheritDoc */
        public function registerState(state:IState, initial:Boolean = false):Boolean {
            if (!state) {
                throw new ArgumentError("state should be not null");
            }

            if (hasState(state.name)) {
                return false;
            }

            addState(state);

            if (initial) {
                if (_initialState) {
                    throw new ArgumentError("Cant be more than one initial states");
                } else{
                    _initialState = state;
                }
            }

            return true;
        }

        /** @inheritDoc */
        public function removeState(stateName:String):Boolean {
            var state:IState = _statesMap[stateName];
            if (state == null) {
                return false;
            }

            delState(state);
            return true;
        }



        private function getStateByAction(action:String):IState {
            if (currentState) {
                var transition:ITransition = currentState.getTransition(action);
                if (transition) {
                    return _statesMap[transition.target];
                }
            }

            return null;
        }

        /**
         * Start transition to state
         * @param action
         * @param data
         * @return true if started
         */
        private function next(action:String, data:Object = null):Boolean {
            if (!canDoTransition(action)) {
                return false;
            }

            _pendingState = getStateByAction(action);

            if (currentState.exiting) {
                _eventDispatcher.dispatchEvent(new StateEvent(currentState.exiting, currentState.name, data));
            }

            if (!pendingState) { // rejected by guard
                return false;
            }

            if (pendingState.entering) {
                _eventDispatcher.dispatchEvent(new StateEvent(pendingState.entering, pendingState.name, data));
            }

            if (!pendingState) { // rejected by guard
                return false;
            }

            _currentTransition = currentState.getTransition(action);
            _history.push(currentState.name);
            _currentState = null;

            if (currentTransition.complete == "") {
                dispatchTransitionComplete(new TransitionEvent(TransitionEvent.COMPLETE, currentTransition.target, data));
            } else {
                _eventDispatcher.addEventListener(currentTransition.complete, dispatchTransitionComplete);
            }
            return true;
        }

        private function completeState(data:Object = null):void {
            _currentState = pendingState;
            _pendingState = null;
            _currentTransition = null;

            if (currentState.complete) {
                _eventDispatcher.dispatchEvent(new StateEvent(currentState.complete, currentState.name, data));
            }

            // Notify the app generally that the state changed and what the new state is
            _eventDispatcher.dispatchEvent(new StateEvent(StateEvent.COMPLETE, currentState.name, data));
        }

        private function addState(state:IState):void {
            _states.push(state);
            _statesMap[state.name] = state;
        }

        private function delState(state:IState):void {
            _states.splice(_states.indexOf(state), 1);
            delete _statesMap[state.name];
        }

        //=====================================================================
        //  Checkers
        //=====================================================================
        private function hasState(stateName:String):Boolean {
            return Boolean(_statesMap[stateName]);
        }

        private function canDoTransition(action:String):Boolean {
            if (!currentState.hasTransition(action)) {
                return false;
            }

            if (!currentState) {
                return false;
            }

            return (currentState.name != currentState.getNextState(action));
        }

        private function get isInTransition():Boolean {
            return Boolean(currentTransition);
        }

        //=====================================================================
        //  Handlers
        //=====================================================================
        private function handleStateAction(event:StateEvent):void {
            if (!isInTransition) {
                next(event.action, event.data);
            } else {
                throw new Error("ups");
            }
        }

        private function handleStateBack(event:StateEvent):void {
        }

        private function handleStateComplete(event:StateEvent):void {
        }

        private function dispatchTransitionComplete(event:TransitionEvent):void {
            _eventDispatcher.dispatchEvent(new TransitionEvent(TransitionEvent.COMPLETE, _currentTransition.target, event.data));
        }

        private function onTransitionComplete(event:TransitionEvent):void {
            if (pendingState && pendingState.name == event.targetState) {
                completeState(event.data);
            }
        }

        private function onTransitionCancel(event:TransitionEvent):void {
            _pendingState = null;
            _currentTransition = null;
        }
    }
}