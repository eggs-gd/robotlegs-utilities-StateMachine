/*
 ADAPTED FOR ROBOTLEGS FROM:
 PureMVC AS3 Utility - StateMachine
 Copyright (c) 2008 Neil Manuell, Cliff Hall
 Your reuse is governed by the Creative Commons Attribution 3.0 License
 */
package robotlegs.bender.util.statemachine.impl {
    import robotlegs.bender.util.statemachine.api.IState;
    import robotlegs.bender.util.statemachine.api.ITransition;


    /**
     * Defines a State.
     */
    public class State implements IState {

        private var _name:String;
        public function get name():String { return _name; }

        private var _entering:String;
        public function get entering():String { return _entering; }

        private var _exiting:String;
        public function get exiting():String { return _exiting; }

        private var _changed:String;
        public function get changed():String { return _changed; }

        /** @inheritDoc */
        protected var _transitions:Vector.<ITransition>;
        public function get transitions():Vector.<ITransition> {
            return _transitions.concat();
        }

        /**
         * Constructor.
         *
         * @param name the id of the state
         * @param entering an optional event name to be sent when entering this state
         * @param exiting an optional event name to be sent when exiting this state
         * @param changed an optional event name to be sent when fully transitioned to this state
         */
        public function State(name:String, entering:String = null, exiting:String = null, changed:String = null) {
            _name = name;
            _entering = entering;
            _exiting = exiting;
            _changed = changed;

            _transitions = new <ITransition>[];
        }

        /** @inheritDoc */
        public function addTransition(transition:ITransition):Boolean {
            if (getTransition(transition.action) == null) {
                _transitions.push(transition);
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

            _transitions.splice(_transitions.indexOf(transition), 1);
            return true;
        }

        /** @inheritDoc */
        public function getTransition(action:String):ITransition {
            for each (var transition:ITransition in _transitions) {
                if (transition.action == action) {
                    return transition;
                }
            }
            return null;
        }

        /** @inheritDoc */
        public function toString():String {
            return "State (name: " + _name + ")";
        }
    }
}