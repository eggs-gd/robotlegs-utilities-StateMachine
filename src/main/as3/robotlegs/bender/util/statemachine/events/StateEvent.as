/**
 * Created by Dukobpa3 on 09.01.2015.
 */
package robotlegs.bender.util.statemachine.events {
    import flash.events.Event;

    import robotlegs.bender.util.statemachine.api.IState;


    /**
     * Event fired from SM to "Big World"
     */
    public class StateEvent extends Event {
        public static const TRANSITION_START:String = "robotlegs.bender.util.statemachine.events.StateEvent.TRANSITION_START";
        public static const TRANSITION_CANCEL:String = "robotlegs.bender.util.statemachine.events.StateEvent.TRANSITION_CANCEL";
        public static const TRANSITION_COMPLETE:String = "robotlegs.bender.util.statemachine.events.StateEvent.TRANSITION_COMPLETE";

        public static const STATE_COMPLETE:String = "robotlegs.bender.util.statemachine.events.StateEvent.STATE_COMPLETE";
        public static const STATE_POP:String = "robotlegs.bender.util.statemachine.events.StateEvent.STATE_POP";

        /**
         * Parent state of this event
         */
        public function get state():IState { return _state; }
        private var _state:IState;


        public function StateEvent(eventType:String, state:IState = null) {
            _state = state;
            super(eventType);
        }

        override public function clone():Event {
            return new StateEvent(type, state);
        }
    }
}
