/*
 ADAPTED FOR ROBOTLEGS FROM:
 PureMVC AS3 Utility - StateMachine
 Copyright (c) 2008 Neil Manuell, Cliff Hall
 Your reuse is governed by the Creative Commons Attribution 3.0 License
 */
package robotlegs.bender.util.statemachine.events {
    import flash.events.Event;


    /**
     * Event about current|pending state's progress
     */
    public class StateEvent extends Event {
        public static const COMPLETE:String = "robotlegs.bender.util.statemachine.impl.StateEvent.COMPLETE";
        public static const BACK:String = "robotlegs.bender.util.statemachine.impl.StateEvent.BACK";

        private var _action:String;
        public function get action():String { return _action; }

        public function StateEvent(eventType:String, action:String) {
            _action = action;
            super(eventType, false, false);
        }

        override public function clone():Event {
            return new StateEvent(type, _action);
        }
    }
}