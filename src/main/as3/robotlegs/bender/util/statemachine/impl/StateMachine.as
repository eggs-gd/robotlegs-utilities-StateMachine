package robotlegs.bender.util.statemachine.impl {
    import flash.events.Event;
    import flash.events.IEventDispatcher;

    import robotlegs.bender.util.statemachine.api.IState;
    import robotlegs.bender.util.statemachine.api.IStateMachine;
    import robotlegs.bender.util.statemachine.api.ITransition;
    import robotlegs.bender.util.statemachine.events.StateEvent;


    public class StateMachine implements IStateMachine {

        //=====================================================================
        //  History
        //=====================================================================
        /** @inheritDoc */
        public function get state():IState { return _state; }
        private var _state:IState;

        /** @inheritDoc */
        public function get pendingState():IState { return _pendingState; } // {stateName:state}
        private var _pendingState:IState;

        /** @inheritDoc */
        public function get transition():ITransition { return _transition; }
        private var _transition:ITransition;

        /** @inheritDoc */
        public function get history():Vector.<String> { return _history.concat(); }
        private var _history:Vector.<String>;

        //=====================================================================
        //  Private params
        //=====================================================================
        private var _eventDispatcher:IEventDispatcher;
        /** Map of States objects by name. */
        private var _states:Vector.<IState>;
        private var _statesMap:Object;
        /** The initial state of the FSM. */
        private var _initialState:IState;

        //=====================================================================
        //  Public methods
        //=====================================================================
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


        /** @inheritDoc */
        public function start():void {
            if (_initialState) {
                _pendingState = _initialState;
                completeState();
            } else {
                throw new DefinitionError("Not registered initial state");
            }
        }

        /** @inheritDoc */
        public function dispose():void {
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

            _states.push(state);
            _statesMap[state.name] = state;

            if (initial) {
                if (_initialState) {
                    throw new ArgumentError("Can't be more than one initial state");
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

            _states.splice(_states.indexOf(state), 1);
            delete _statesMap[state.name];

            return true;
        }

        //=====================================================================
        //  Private methods
        //=====================================================================
        private function getStateByAction(action:String):IState {
            if (state && state.hasTransition(action)) {
                return _statesMap[state.getTransition(action).target];
            }
            return null;
        }

        /**
         * Start transition to state
         * @param action
         * @return true if started
         */
        private function next(action:String):Boolean {
            if (!canDoTransition(action)) {
                return false;
            }

            _pendingState = getStateByAction(action);
            _transition = state.getTransition(action);
            _eventDispatcher.addEventListener(transition.cancel, onTransitionCancel);

            if (pendingState.entering) {
                _eventDispatcher.dispatchEvent(new StateEvent(pendingState.entering, pendingState));
                if (!pendingState) { // rejected by guard
                    return false;
                }
            }

            _eventDispatcher.dispatchEvent(new StateEvent(StateEvent.STATE_START, pendingState));

            for each (var trans:ITransition in state.transitions) {
                _eventDispatcher.removeEventListener(trans.action, onStateAction);
            }
            for each (var popAction:String in state.popActions) {
                _eventDispatcher.removeEventListener(popAction, onStateBack);
            }

            _history.push(state.name);
            _state = null;

            if (transition.isInstant) {
                completeState();
            } else {
                _eventDispatcher.addEventListener(transition.complete, onTransitionComplete);
            }
            return true;
        }

        private function back():Boolean {
            _pendingState = _statesMap[_history.pop()];

            if (state.exiting) {
                _eventDispatcher.dispatchEvent(new StateEvent(state.exiting, state));
                if (!pendingState) { // rejected by guard
                    return false;
                }
            }

            for each (var trans:ITransition in state.transitions) {
                _eventDispatcher.removeEventListener(trans.action, onStateAction);
            }
            for each (var popAction:String in state.popActions) {
                _eventDispatcher.removeEventListener(popAction, onStateBack);
            }

            _state = pendingState;
            _pendingState = null;

            for each (trans in state.transitions) {
                _eventDispatcher.addEventListener(trans.action, onStateAction);
            }

            for each (popAction in state.popActions) {
                _eventDispatcher.addEventListener(popAction, onStateBack);
            }

            _eventDispatcher.dispatchEvent(new StateEvent(StateEvent.STATE_READY, state));

            return true;
        }

        /**
         * @param silence needed for cancelling transition. If true then don't dispatch state complete
         */
        private function completeState(silence:Boolean = false):void {
            _state = pendingState;
            _pendingState = null;

            _transition = null;
            for each (var trans:ITransition in state.transitions) {
                _eventDispatcher.addEventListener(trans.action, onStateAction);
            }

            for each (var popAction:String in state.popActions) {
                _eventDispatcher.addEventListener(popAction, onStateBack);
            }

            if (silence) {
                return;
            }

            // Notify the app generally that the state changed and what the new state is
            _eventDispatcher.dispatchEvent(new StateEvent(StateEvent.STATE_READY, state));
            if (state.complete) {
                _eventDispatcher.dispatchEvent(new StateEvent(state.complete, state));
            }
        }

        //=====================================================================
        //  Handlers
        //=====================================================================
        private function onStateAction(event:Event):void {
            if (!transition) {
                next(event.type);
            } else {
                // TODO add states queue
            }
        }

        private function onStateBack(event:Event):void {
            _eventDispatcher.dispatchEvent(new StateEvent(StateEvent.STATE_POP, state));
            back();
        }

        private function onTransitionComplete(event:Event):void {
            _eventDispatcher.removeEventListener(transition.complete, onTransitionComplete);
            completeState();
        }

        private function onTransitionCancel(event:Event):void {
            _eventDispatcher.removeEventListener(transition.complete, onTransitionComplete);
            _eventDispatcher.removeEventListener(transition.cancel, onTransitionCancel);
            _eventDispatcher.dispatchEvent(new StateEvent(StateEvent.STATE_CANCEL, pendingState));
            // TODO investigate and fix cancelling flow
            if (state) { // it means that we already closed state but not opened next
                _pendingState = state;
            } else {
                _pendingState = _statesMap[_history.pop()];
            }
            completeState(true);
        }

        //=====================================================================
        //  Checkers
        //=====================================================================
        private function canDoTransition(action:String):Boolean {
            if (!state || !state.hasTransition(action)) {
                return false;
            } else {
                return (state.name != state.getNextState(action));
            }
        }
    }
}
