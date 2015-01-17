package robotlegs.bender.util.statemachine.impl {
    import robotlegs.bender.util.statemachine.api.IState;
    import robotlegs.bender.util.statemachine.api.ITransition;


    /**
     * Defines a State.
     */
    public class State implements IState {

        /** @inheritDoc */
        public function get name():String { return _name; }
        private var _name:String;

        /** @inheritDoc */
        public function get entering():String { return _entering; }
        private var _entering:String;

        /** @inheritDoc */
        public function get exiting():String { return _exiting; }
        private var _exiting:String;

        /** @inheritDoc */
        public function get complete():String { return _complete; }
        private var _complete:String;

        /** @inheritDoc */
        public function get transitions():Vector.<ITransition> { return _transitions.concat(); }
        private var _transitions:Vector.<ITransition>;
        private var _transitionsMap:Object; // {action:transition}

        /** @inheritDoc */
        public function get popActions():Vector.<String> { return _popActions.concat(); }
        private var _popActions:Vector.<String>;


        /**
         * Constructor.
         *
         * @param name the id of the state
         * @param entering an optional event name to be sent when entering this state
         * @param exiting an optional event name to be sent when exiting this state
         * @param complete an optional event name to be sent when fully transitioned to this state
         */
        public function State(name:String, entering:String = null, exiting:String = null, complete:String = null) {
            _name = name;
            _entering = entering;
            _exiting = exiting;
            _complete = complete;

            _popActions = new <String>[];
            _transitions = new <ITransition>[];
            _transitionsMap = {};
        }

        /** @inheritDoc */
        public function addPopAction(action:String):Boolean {
            if (_popActions.indexOf(action) < 0 ) {
                _popActions.push(action);
                return true;
            }
            return false;
        }

        /** @inheritDoc */
        public function addTransition(transition:ITransition):Boolean {
            if (getTransition(transition.action) == null) {
                addTrans(transition);
                return true;
            }
            return false;
        }

        /** @inheritDoc */
        public function removeTransition(action:String):Boolean {
            var transition:ITransition = getTransition(action);
            if(transition == null) {
                return false;
            }

            delTrans(transition);
            return true;
        }

        /** @inheritDoc */
        public function getTransition(action:String):ITransition {
            for each (var transition:ITransition in transitions) {
                if (transition.action == action) {
                    return transition;
                }
            }
            return null;
        }

        public function getNextState(actionName:String):String {
            if (hasTransition(actionName)) {
                return getTransition(actionName).target
            }
            return null;
        }

        public function hasTransition(action:String):Boolean {
            return Boolean(getTransition(action));
        }

        private function addTrans(transition:ITransition):void {
            _transitions.push(transition);
            _transitionsMap[transition.action] = transition;
        }

        private function delTrans(transition:ITransition):void {
            _transitions.splice(transitions.indexOf(transition), 1);
            delete _transitionsMap[transition.action];
        }
    }
}