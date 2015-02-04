/**
 * Created by Dukobpa3 on 09.01.2015.
 */
package robotlegs.bender.util.statemachine {
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;

    import org.flexunit.Assert;

    import robotlegs.bender.util.fsmInjector.impl.FSMInjector;
    import robotlegs.bender.util.statemachine.impl.StateMachine;


    public class CancellingTests {
        private static const STATE_INIT:String = "state/init";

        private static const ACTION_READY:String = "action/ready";
        private static const ACTION_READY_CANCEL:String = "action/ready_cancel";
        private static const EVENT_TRANSITION_COMPLETE:String = "event/transition_complete";

        private static const STATE_READY:String = "state/ready";
        private static const STATE_READY_CHANGED:String = "event/ready_changed";
        private static const STATE_READY_POP_ACTION:String = "event/ready_back";



        private static const FSM:XML = <fsm initial={STATE_INIT}>
            <state name={STATE_INIT}>
                <transition action={ACTION_READY} target={STATE_READY} cancel={ACTION_READY_CANCEL} complete={EVENT_TRANSITION_COMPLETE}/>
            </state>

            <state name={STATE_READY} complete={STATE_READY_CHANGED}>
                <pop action={STATE_READY_POP_ACTION} />
            </state>
        </fsm>;

        private var eventDispatcher:IEventDispatcher;
        private var stateMachine:StateMachine;

        [Before]
        public function runBeforeEachTest():void {
            eventDispatcher = new EventDispatcher();
            stateMachine = new StateMachine(eventDispatcher);
            new FSMInjector(FSM).inject(stateMachine);
        }

        [After]
        public function runAfterEachTest():void {
            eventDispatcher = null;
            stateMachine = null;
        }

        [Test]
        public function pausedNextState():void {
            Assert.assertEquals(STATE_INIT, stateMachine.state.name);

            eventDispatcher.dispatchEvent(new Event(ACTION_READY));
            Assert.assertNull(stateMachine.state);
            Assert.assertEquals(STATE_READY, stateMachine.pendingState.name);
        }

        [Test]
        public function cancelTransitionState():void {
            eventDispatcher.dispatchEvent(new Event(ACTION_READY));
            Assert.assertNull(stateMachine.state);

            eventDispatcher.dispatchEvent(new Event(ACTION_READY_CANCEL));
            Assert.assertNotNull(stateMachine.state);
            Assert.assertEquals(STATE_INIT, stateMachine.state.name);

            eventDispatcher.dispatchEvent(new Event(EVENT_TRANSITION_COMPLETE));
            Assert.assertNotNull(stateMachine.state);
            Assert.assertEquals(STATE_INIT, stateMachine.state.name);
        }
    }
}
