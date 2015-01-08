/*
 ADAPTED FOR ROBOTLEGS FROM:
 PureMVC AS3 Utility - StateMachine
 Copyright (c) 2008 Neil Manuell, Cliff Hall
 Your reuse is governed by the Creative Commons Attribution 3.0 License
 */
package robotlegs.bender.util.statemachine.impl {
    import flash.events.Event;


    public class TransitionEvent extends Event {
        public static const START:String = "robotlegs.bender.util.statemachine.impl.TransitionEvent.START";
        public static const CANCEL:String = "robotlegs.bender.util.statemachine.impl.TransitionEvent.CANCEL";
        public static const COMPLETE:String = "robotlegs.bender.util.statemachine.impl.TransitionEvent.COMPLETE";


        /** target state name */
        public function get targetState():String { return _targetState; }
        private var _targetState:String;

        /** Additional data for setting up state */
        public function get data():Object { return _data; }
        private var _data:Object;

        public function TransitionEvent(eventType:String, targetState:String, data:Object = null) {
            _targetState = targetState;
            _data = data;
            super(eventType, false, false);
        }

        /** @inheritDoc */
        override public function clone():Event {
            return new StateEvent(type, _targetState, _data);
        }
    }
}