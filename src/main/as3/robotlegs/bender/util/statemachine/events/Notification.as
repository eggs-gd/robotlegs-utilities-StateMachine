/**
 * Created by Dukobpa3 on 09.01.2015.
 */
package robotlegs.bender.util.statemachine.events {
    import flash.events.Event;

    import robotlegs.bender.util.statemachine.api.IState;


    /**
     * Event fired from SM to "Big World"
     */
    public class Notification extends Event {

        private var _state:IState;
        public function get state():IState { return _state; }

        public function Notification(eventType:String, state:IState = null) {
            _state = state;
            super(eventType);
        }

        override public function clone():Event {
            return new Notification(type, state);
        }
    }
}
