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
        public function get history():Vector.<String> { return _history.concat(); }
        private var _history:Vector.<String>;

        /** @inheritDoc */
        public function get state():IState { return _state; }
        private var _state:IState;

        /** @inheritDoc */
        public function get pendingState():IState { return _pendingState; }
        private var _pendingState:IState;

        /** @inheritDoc */
        public function get transition():ITransition { return _transition; }
        private var _transition:ITransition;

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
            if (_initialState) {
                _pendingState = _initialState;
                completeState();
            } else {
                throw new DefinitionError("Not registered initial state");
            }
        }

        /** @inheritDoc */
        public function onRemove():void {
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
            _eventDispatcher.dispatchEvent(new StateEvent(StateEvent.TRANSITION_START, pendingState));

            if (pendingState.entering) {
                _eventDispatcher.dispatchEvent(new StateEvent(pendingState.entering, pendingState));
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

            return true;
        }

        private function completeState():void {
            _state = pendingState;
            _pendingState = null;

            if (state.complete) {
                _eventDispatcher.dispatchEvent(new StateEvent(state.complete, state));
            }

            _transition = null;
            for each (var trans:ITransition in state.transitions) {
                _eventDispatcher.addEventListener(trans.action, onStateAction);
            }

            for each (var popAction:String in state.popActions) {
                _eventDispatcher.addEventListener(popAction, onStateBack);
            }

            // Notify the app generally that the state changed and what the new state is
            _eventDispatcher.dispatchEvent(new StateEvent(StateEvent.TRANSITION_COMPLETE, state));
            _eventDispatcher.dispatchEvent(new StateEvent(StateEvent.STATE_COMPLETE, state));
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
            if (!transition) {
                next(event.type);
            } else {
                // TODO queue
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
            _eventDispatcher.removeEventListener(transition.cancel, onTransitionCancel);
            _eventDispatcher.dispatchEvent(new StateEvent(StateEvent.TRANSITION_CANCEL, pendingState));
            _pendingState = null;
            _transition = null;
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