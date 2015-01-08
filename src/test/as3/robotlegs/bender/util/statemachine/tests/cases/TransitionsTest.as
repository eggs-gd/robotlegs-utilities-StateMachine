package robotlegs.bender.util.statemachine.tests.cases {
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;

    import org.flexunit.Assert;

    import robotlegs.bender.util.fsmInjector.impl.FSMInjector;
    import robotlegs.bender.util.statemachine.impl.StateEvent;
    import robotlegs.bender.util.statemachine.impl.StateMachine;
    import robotlegs.bender.util.statemachine.impl.TransitionEvent;


    public class TransitionsTest {

        private static const STATE_INIT:String = "state/init";

        private static const ACTION_READY:String = "action/ready";
        private static const EVENT_TRANSITION_COMPLETE:String = "event/transition_complete";

        private static const STATE_READY:String = "state/ready";
        private static const STATE_READY_CHANGED:String = "event/ready_changed";

        private static const FSM:XML = <fsm initial={STATE_INIT}>
                <state name={STATE_INIT}>
                        <transition action={ACTION_READY} target={STATE_READY} complete={EVENT_TRANSITION_COMPLETE}/>
                </state>

                <state name={STATE_READY} complete={STATE_READY_CHANGED}/>
        </fsm>;

        private var eventDispatcher:IEventDispatcher;
        private var fsmInjector:FSMInjector;
        private var stateMachine:StateMachine;

        [Before]
        public function runBeforeEachTest():void {
            eventDispatcher = new EventDispatcher();
            fsmInjector = new FSMInjector(FSM);
            stateMachine = new StateMachine(eventDispatcher);
            fsmInjector.inject(stateMachine);
        }

        [After]
        public function runAfterEachTest():void {
            fsmInjector = null;
        }

        [Test]
        public function fsmIsInitialized():void {
            Assert.assertEquals(true, stateMachine is StateMachine);
            Assert.assertEquals(STATE_INIT, stateMachine.currentState.name);
        }

        [Test]
        public function pausedNextState():void {
            eventDispatcher.dispatchEvent(new StateEvent(StateEvent.ACTION, ACTION_READY));
            Assert.assertNull(STATE_INIT, stateMachine.currentState);
            Assert.assertEquals(STATE_READY, stateMachine.pendingState.name);
        }

        [Test]
        public function completeNextState():void {
            eventDispatcher.dispatchEvent(new StateEvent(StateEvent.ACTION, ACTION_READY));
            Assert.assertNull(stateMachine.currentState);

            eventDispatcher.dispatchEvent(new TransitionEvent(EVENT_TRANSITION_COMPLETE, STATE_READY));
            Assert.assertEquals(STATE_READY, stateMachine.currentState.name);
        }
    }
}
