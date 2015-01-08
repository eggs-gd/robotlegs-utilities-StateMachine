package robotlegs.bender.util.statemachine.tests.cases {
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;

    import org.flexunit.Assert;

    import robotlegs.bender.util.fsmInjector.impl.FSMInjector;
    import robotlegs.bender.util.statemachine.impl.StateEvent;
    import robotlegs.bender.util.statemachine.impl.StateMachine;


    public class TransitionsTest {

        private static const STATE_INIT:String = "state/init";

        private static const ACTION_READY:String = "action/ready";
        private static const EVENT_TRANSITION_COMPLETE:String = "event/transition_complete";

        private static const STATE_READY:String = "state/ready";
        private static const STATE_READY_CHANGED:String = "event/ready_changed";

        private static const FSM:XML = <fsm initial={STATE_INIT}>
                <state name={STATE_INIT}>
                        <transition action={ACTION_READY} target={STATE_READY} completed={EVENT_TRANSITION_COMPLETE}/>
                </state>

                <state name={STATE_READY} changed={STATE_READY_CHANGED}/>
        </fsm>;

        private var eventDispatcher:IEventDispatcher;
        private var fsmInjector:FSMInjector;

        [Before]
        public function runBeforeEachTest():void {
            eventDispatcher = new EventDispatcher();
            fsmInjector = new FSMInjector(FSM);
        }

        [After]
        public function runAfterEachTest():void {
            fsmInjector = null;
        }

        [Test]
        public function fsmIsInitialized():void {
            var stateMachine:StateMachine = new StateMachine(eventDispatcher);
            fsmInjector.inject(stateMachine);
            Assert.assertEquals(true, stateMachine is StateMachine);
            Assert.assertEquals(STATE_INIT, stateMachine.currentState.name);
        }

        [Test]
        public function pausedNextState():void {
            var stateMachine:StateMachine = new StateMachine(eventDispatcher);
            fsmInjector.inject(stateMachine);
            eventDispatcher.dispatchEvent(new StateEvent(StateEvent.ACTION, ACTION_READY));
            Assert.assertEquals(STATE_INIT, stateMachine.currentState.name);
        }
    }
}
