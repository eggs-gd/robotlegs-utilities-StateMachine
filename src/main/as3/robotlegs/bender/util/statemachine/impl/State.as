/*
 ADAPTED FOR ROBOTLEGS FROM:
 PureMVC AS3 Utility - StateMachine
 Copyright (c) 2008 Neil Manuell, Cliff Hall
 Your reuse is governed by the Creative Commons Attribution 3.0 License
 */
package robotlegs.bender.util.statemachine.impl {
    import robotlegs.bender.util.statemachine.api.IState;


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

        /**
         *  Transition map of actions to target states
         */
        protected var _transitions:Object;


        /**
         * Constructor.
         *
         * @param name the id of the state
         * @param entering an optional event name to be sent when entering this state
         * @param exiting an optional event name to be sent when exiting this state
         * @param changed an optional event name to be sent when fully transitioned to this state
         */
        public function State(name:String, entering:String = null, exiting:String = null, changed:String = null) {

            _transitions = {};

            _name = name;
            _entering = entering;
            _exiting = exiting;
            _changed = changed;
        }

        /**
         * Define a transition.
         *
         * @param action the name of the StateMachine.ACTION event type.
         * @param target the name of the target state to transition to.
         */
        public function defineTransition(action:String, target:String):void {
            if (getTarget(action) == null) {
                _transitions[action] = target;
            }
        }

        /**
         * Remove a previously defined transition.
         */
        public function removeTransition(action:String):void {
            delete _transitions[action];
        }

        /**
         * Get the target state name for a given action.
         */
        public function getTarget(action:String):String {
            return _transitions[action];
        }

        /**
         * Utils
         */
        public function toString():String {
            return "State (name: " + _name + ")";
        }
    }
}