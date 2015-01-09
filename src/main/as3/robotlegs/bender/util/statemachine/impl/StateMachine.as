/*
 ADAPTED FOR ROBOTLEGS FROM:
 PureMVC AS3 Utility - StateMachine
 Copyright (c) 2008 Neil Manuell, Cliff Hall
 Your reuse is governed by the Creative Commons Attribution 3.0 License
 */
package robotlegs.bender.util.statemachine.impl {
    import flash.events.Event;
    import flash.events.IEventDispatcher;

    import robotlegs.bender.util.statemachine.api.IState;
    import robotlegs.bender.util.statemachine.api.IStateMachine;
    import robotlegs.bender.util.statemachine.api.ITransition;
    import robotlegs.bender.util.statemachine.events.Notification;
    import robotlegs.bender.util.statemachine.events.StateEvent;
    import robotlegs.bender.util.statemachine.events.TransitionEvent;


    public class StateMachine implements IStateMachine {

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
        //  Private params
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

        //=====================================================================
        //  Public methods
        //=====================================================================

        /** @inheritDoc */
        public function onRegister():void {
            _eventDispatcher.addEventListener(StateEvent.BACK, onStateBack);

            if (_initialState) {
                _pendingState = _initialState;
                completeState();
            } else {
                throw new DefinitionError("Not registered initial state");
            }
        }

        /** @inheritDoc */
        public function onRemove():void {
            _eventDispatcher.removeEventListener(StateEvent.BACK, onStateBack);
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

            if (Boolean(_statesMap[state.name])) { // already registered
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

        //=====================================================================
        //  Private methods
        //=====================================================================
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
        private function next(action:String):Boolean {
            if (!canDoTransition(action)) {
                return false;
            }

            _pendingState = getStateByAction(action);
            _currentTransition = currentState.getTransition(action);
            _eventDispatcher.addEventListener(currentTransition.cancel, onTransitionCancel);
            _eventDispatcher.dispatchEvent(new TransitionEvent(TransitionEvent.START, pendingState.name));

            if (currentState.exiting) {
                _eventDispatcher.dispatchEvent(new Notification(currentState.exiting, currentState));
                if (!pendingState) { // rejected by guard
                    return false;
                }
            }

            if (pendingState.entering) {
                _eventDispatcher.dispatchEvent(new Notification(pendingState.entering, pendingState));
                if (!pendingState) { // rejected by guard
                    return false;
                }
            }

            for each (var transition:ITransition in currentState.transitions) {
                _eventDispatcher.removeEventListener(transition.action, onStateAction);
            }

            _history.push(currentState.name);
            _currentState = null;

            if (currentTransition.complete == "") {
                completeState();
            } else {
                _eventDispatcher.addEventListener(currentTransition.complete, onTransitionComplete);
            }
            return true;
        }

        private function completeState():void {
            _currentState = pendingState;
            _pendingState = null;

            if (currentState.complete) {
                _eventDispatcher.dispatchEvent(new Notification(currentState.complete, currentState));
            }

            _currentTransition = null;
            for each (var transition:ITransition in currentState.transitions) {
                _eventDispatcher.addEventListener(transition.action, onStateAction);
            }

            // Notify the app generally that the state changed and what the new state is
            _eventDispatcher.dispatchEvent(new TransitionEvent(TransitionEvent.COMPLETE, currentState.name));
            _eventDispatcher.dispatchEvent(new StateEvent(StateEvent.COMPLETE, currentState.name));
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
        //  Handlers
        //=====================================================================
        private function onStateAction(event:Event):void {
            if (!currentTransition) {
                next(event.type);
            } else {
                throw new Error("ups");
            }
        }

        private function onStateBack(event:Event):void {
        }

        private function onTransitionComplete(event:Event):void {
            _eventDispatcher.removeEventListener(currentTransition.complete, onTransitionComplete);
            completeState();
        }

        private function onTransitionCancel(event:Event):void {
            _eventDispatcher.removeEventListener(currentTransition.cancel, onTransitionCancel);
            _pendingState = null;
            _currentTransition = null;
        }

        //=====================================================================
        //  Checkers
        //=====================================================================
        private function canDoTransition(action:String):Boolean {
            if (!currentState || !currentState.hasTransition(action)) {
                return false;
            } else {
                return (currentState.name != currentState.getNextState(action));
            }
        }
    }
}