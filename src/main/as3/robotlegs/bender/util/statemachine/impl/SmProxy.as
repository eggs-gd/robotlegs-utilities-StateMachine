package robotlegs.bender.util.statemachine.impl {
    import robotlegs.bender.util.statemachine.api.ISmPublicProxy;
    import robotlegs.bender.util.statemachine.api.IStateMachine;


    public class SmProxy implements ISmPublicProxy {

        private var _sm:IStateMachine;

        public function SmProxy(sm:IStateMachine) {
            _sm = sm;
        }

        public function get state():String {
            return _sm.state.name;
        }

        public function get pendingState():String {
            return _sm.pendingState.name;
        }

        public function get transition():Boolean {
            return Boolean(_sm.transition);
        }

        public function get history():Vector.<String> {
            return _sm.history;
        }
    }
}
