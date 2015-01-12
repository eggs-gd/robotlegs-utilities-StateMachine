package robotlegs.bender.util.statemachine.impl {
    import robotlegs.bender.util.statemachine.api.ITransition;


    public class Transition implements ITransition {

        /** @inheritDoc */
        public function get action():String { return _action; }
        private var _action:String;

        /** @inheritDoc */
        public function get cancel():String { return _cancel; }
        private var _cancel:String;

        /** @inheritDoc */
        public function get target():String { return _target; }
        private var _target:String;

        /** @inheritDoc */
        public function get complete():String { return _complete; }
        private var _complete:String;

        /** @inheritDoc */
        public function get isInstant():Boolean { return !complete || complete == ""; }

        public function Transition(action:String, target:String, complete:String = "", cancel:String = "") {
            _action = action;
            _target = target;

            _complete = complete;
            _cancel = cancel;
        }
    }
}
