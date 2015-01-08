/*
 ADAPTED FOR ROBOTLEGS FROM:
 PureMVC AS3 Utility - StateMachine
 Copyright (c) 2008 Neil Manuell, Cliff Hall
 Your reuse is governed by the Creative Commons Attribution 3.0 License
 */
package robotlegs.bender.util.statemachine.impl {
    import flash.events.Event;


    public class StateEvent extends Event {
        public static const ACTION:String = "robotlegs.bender.util.statemachine.impl.StateEvent.ACTION";
        public static const COMPLETE:String = "robotlegs.bender.util.statemachine.impl.StateEvent.COMPLETE";
        public static const BACK:String = "robotlegs.bender.util.statemachine.impl.StateEvent.BACK";

        private var _action:String;
        public function get action():String { return _action; }

        private var _data:Object;
        public function get data():Object { return _data; }

        public function StateEvent(eventType:String, action:String, data:Object = null) {
            _action = action;
            _data = data;
            super(eventType, false, false);
        }

        override public function clone():Event {
            return new StateEvent(type, _action, _data);
        }
    }
}