package robotlegs.bender.util.statemachine {
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;

    import org.flexunit.Assert;

    import robotlegs.bender.util.fsmInjector.impl.FSMInjector;
    import robotlegs.bender.util.statemachine.events.StateEvent;
    import robotlegs.bender.util.statemachine.impl.StateMachine;


    public class StateMachineTests {
        private static const STARTING:String = "state/starting";
        private static const STARTED:String = "action/completed/start";
        private static const START_FAILED:String = "action/start/failed";

        private static const CONSTRUCTING:String = "state/constructing";
        private static const CONSTRUCT:String = "event/construct";
        private static const CONSTRUCTION_EXIT:String = "event/construction/exit";

        private static const CONSTRUCTED:String = "action/completed/construction";
        private static const CONSTRUCTED_CANCEL:String = "action/cancel/construction";
        private static const CONSTRUCTION_FAILED:String = "action/construction/failed";

        private static const NAVIGATING:String = "state/navigating";
        private static const NAVIGATE_ENTERING:String = "action/navigate/entering";
        private static const NAVIGATE:String = "event/navigate";

        ////////
        // State Machine Constants and Vars
        ///////
        private static const FAILING:String = "state/failing";
        private static const FAIL:String = "event/fail";

        private static const FSM:XML =
                <fsm initial={STARTING}>

                    <!-- The simple state. No guards, no addition events fired -->
                    <state name={STARTING}>
                        <transition action={STARTED} target={CONSTRUCTING}/>
                        <transition action={START_FAILED} target={FAILING}/>
                    </state>

                    <!-- This state fires complete and exiting events. Can be guarded at "exiting"-->
                    <state  name={CONSTRUCTING}
                            complete={CONSTRUCT}
                            exiting={CONSTRUCTION_EXIT}>

                        <!-- This transition can be cancelled by firing new Event(CONSTRUCTED_CANCEL) -->
                        <transition action={CONSTRUCTED} cancel={CONSTRUCTED_CANCEL} target={NAVIGATING}/>
                        <transition action={CONSTRUCTION_FAILED} target={FAILING}/>
                    </state>

                    <!-- This state can be guarded at entering phase and waiting for external event for complete -->
                    <state name={NAVIGATING} entering={NAVIGATE_ENTERING} complete={NAVIGATE}/>

                    <!-- Other simple state -->
                    <state name={FAILING} complete={FAIL}/>

                </fsm>;

        private var eventDispatcher:IEventDispatcher;
        private var stateMachine:StateMachine;

        [Before]
        public function runBeforeEachTest():void {
            eventDispatcher = new EventDispatcher();
            eventDispatcher.addEventListener(StateEvent.STATE_START, onTransitionStart);

            stateMachine = new StateMachine(eventDispatcher);
            new FSMInjector(FSM).inject(stateMachine);
        }

        [After]
        public function runAfterEachTest():void {
            eventDispatcher = null;
            stateMachine = null;
        }

        [Test]
        public function fsmIsInitialized():void {
            Assert.assertEquals(true, stateMachine is StateMachine);
            Assert.assertEquals(STARTING, stateMachine.state.name);
        }

        [Test]
        public function advanceToNextState():void {
            eventDispatcher.dispatchEvent(new Event(STARTED));
            Assert.assertEquals(CONSTRUCTING, stateMachine.state.name);
        }

        [Test]
        public function constructionStateFailure():void {
            eventDispatcher.dispatchEvent(new Event(STARTED));
            Assert.assertEquals(CONSTRUCTING, stateMachine.state.name);

            eventDispatcher.dispatchEvent(new Event(CONSTRUCTION_FAILED));
            Assert.assertEquals(FAILING, stateMachine.state.name);
        }

        [Test]
        public function stateMachineComplete():void {
            eventDispatcher.dispatchEvent(new Event(STARTED));
            Assert.assertEquals(CONSTRUCTING, stateMachine.state.name);

            eventDispatcher.dispatchEvent(new Event(CONSTRUCTED));
            Assert.assertEquals(NAVIGATING, stateMachine.state.name);
        }

        [Test]
        public function cancelStateChange():void {
            eventDispatcher.dispatchEvent(new Event(STARTED));
            Assert.assertEquals(CONSTRUCTING, stateMachine.state.name);

            //listen for CONSTRUCTION_EXIT and block transition to next state
            eventDispatcher.addEventListener(NAVIGATE_ENTERING, navigateEnterGuard);

            //attempt to complete construction
            eventDispatcher.dispatchEvent(new Event(CONSTRUCTED));
            Assert.assertEquals(CONSTRUCTING, stateMachine.state.name);
        }

        private function onTransitionStart(event:StateEvent):void {
            trace(event.state.name);
        }

        private function navigateEnterGuard(event:StateEvent):void {
            eventDispatcher.dispatchEvent(new Event(CONSTRUCTED_CANCEL));
        }
    }
}