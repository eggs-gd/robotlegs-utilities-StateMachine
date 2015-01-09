package robotlegs.bender.util.statemachine.tests.cases {
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;

    import org.flexunit.Assert;
    import org.flexunit.async.Async;

    import robotlegs.bender.util.fsmInjector.impl.FSMInjector;
    import robotlegs.bender.util.statemachine.events.Notification;
    import robotlegs.bender.util.statemachine.events.StateEvent;
    import robotlegs.bender.util.statemachine.impl.StateMachine;
    import robotlegs.bender.util.statemachine.events.TransitionEvent;


    public class StateMachineTests {
        private static const STARTING:String = "state/starting";
        private static const STARTED:String = "action/completed/start";
        private static const START_FAILED:String = "action/start/failed";

        private static const CONSTRUCTING:String = "state/constructing";
        private static const CONSTRUCT:String = "event/construct";
        private static const CONSTRUCT_ENTERING:String = "action/construct/entering";
        private static const CONSTRUCTION_EXIT:String = "event/construction/exit";

        private static const CONSTRUCTED:String = "action/completed/construction";
        private static const CONSTRUCTED_CANCEL:String = "action/cancel/construction";
        private static const CONSTRUCTION_FAILED:String = "action/construction/failed";

        private static const NAVIGATING:String = "state/navigating";
        private static const NAVIGATE:String = "event/navigate";

        ////////
        // State Machine Constants and Vars
        ///////
        private static const FAILING:String = "state/failing";
        private static const FAIL:String = "event/fail";

        private static const FSM:XML =
                <fsm initial={STARTING}>

                    <!-- THE INITIAL STATE -->
                    <state name={STARTING}>
                        <transition action={STARTED} target={CONSTRUCTING}/>
                        <transition action={START_FAILED} target={FAILING}/>
                    </state>

                    <!-- DOING SOME WORK -->
                    <state  name={CONSTRUCTING}
                            complete={CONSTRUCT}
                            entering={CONSTRUCT_ENTERING}
                            exiting={CONSTRUCTION_EXIT} >

                        <transition action={CONSTRUCTED} cancel={CONSTRUCTED_CANCEL} target={NAVIGATING}/>
                        <transition action={CONSTRUCTION_FAILED} target={FAILING}/>
                    </state>

                    <!-- READY TO ACCEPT BROWSER OR USER NAVIGATION -->
                    <state name={NAVIGATING} complete={NAVIGATE}/>

                    <!-- REPORT FAILURE FROM ANY STATE -->
                    <state name={FAILING} complete={FAIL}/>

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
        public function fsmIsInitialized():void {
            Assert.assertEquals(true, stateMachine is StateMachine);
            Assert.assertEquals(STARTING, stateMachine.currentState.name);
        }

        [Test]
        public function advanceToNextState():void {
            eventDispatcher.dispatchEvent(new Event(STARTED));
            Assert.assertEquals(CONSTRUCTING, stateMachine.currentState.name);
        }

        [Test]
        public function constructionStateFailure():void {
            eventDispatcher.dispatchEvent(new Event(STARTED));
            Assert.assertEquals(CONSTRUCTING, stateMachine.currentState.name);

            eventDispatcher.dispatchEvent(new Event(CONSTRUCTION_FAILED));
            Assert.assertEquals(FAILING, stateMachine.currentState.name);
        }

        [Test]
        public function stateMachineComplete():void {
            eventDispatcher.dispatchEvent(new Event(STARTED));
            Assert.assertEquals(CONSTRUCTING, stateMachine.currentState.name);

            eventDispatcher.dispatchEvent(new Event(CONSTRUCTED));
            Assert.assertEquals(NAVIGATING, stateMachine.currentState.name);
        }

        [Test]
        public function cancelStateChange():void {
            eventDispatcher.dispatchEvent(new Event(STARTED));
            Assert.assertEquals(CONSTRUCTING, stateMachine.currentState.name);

            //listen for CONSTRUCTION_EXIT and block transition to next state
            eventDispatcher.addEventListener(CONSTRUCTION_EXIT, constructionExitGuard);

            //attempt to complete construction
            eventDispatcher.dispatchEvent(new Event(CONSTRUCTED));
            Assert.assertEquals(CONSTRUCTING, stateMachine.currentState.name);
        }

        private function constructionExitGuard(event:Notification):void {
            eventDispatcher.dispatchEvent(new Event(CONSTRUCTED_CANCEL));
        }
    }
}