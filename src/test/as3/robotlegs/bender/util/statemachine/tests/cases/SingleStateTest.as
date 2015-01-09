/**
 * Created by Dukobpa3 on 09.01.2015.
 */
package robotlegs.bender.util.statemachine.tests.cases {
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;

    import org.flexunit.Assert;

    import robotlegs.bender.util.fsmInjector.impl.FSMInjector;
    import robotlegs.bender.util.statemachine.impl.StateMachine;


    public class SingleStateTest {

        private static const STARTING:String = "state/starting";
        private static const START_ENTERING:String = "action/start/entering";
        private static const STARTED:String = "action/completed/start";

        private static const FSM_ONE_STATE:XML =
                <fsm initial={STARTING}>

                    <!-- THE INITIAL STATE -->
                    <state name={STARTING} entering={START_ENTERING}>

                    </state>
                </fsm>;

        private var eventDispatcher:IEventDispatcher;
        private var fsmInjector:FSMInjector;
        private var stateMachine:StateMachine;

        [Before]
        public function runBeforeEachTest():void {
            eventDispatcher = new EventDispatcher();
            fsmInjector = new FSMInjector(FSM_ONE_STATE);
            stateMachine = new StateMachine(eventDispatcher);
            fsmInjector.inject(stateMachine);
        }

        [After]
        public function runAfterEachTest():void {
            fsmInjector = null;
            eventDispatcher = null;
            fsmInjector = null;
            stateMachine = null;
        }


        [Test]
        public function singleStateInConfigurationShouldBeAtThatStateInitially():void {
            Assert.assertEquals("State should be starting", STARTING, stateMachine.currentState.name);
        }

        [Test]
        public function singleStateInConfigurationShouldStayInStateOnCompletionEvent():void {
            eventDispatcher.dispatchEvent(new Event(STARTED));
            Assert.assertEquals("State should be starting", STARTING, stateMachine.currentState.name);
        }
    }
}
