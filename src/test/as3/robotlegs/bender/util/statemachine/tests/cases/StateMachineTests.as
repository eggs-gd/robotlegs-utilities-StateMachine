package robotlegs.bender.util.statemachine.tests.cases {
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;

    import org.flexunit.Assert;
    import org.flexunit.async.Async;

    import robotlegs.bender.util.fsmInjector.impl.FSMInjector;
    import robotlegs.bender.util.statemachine.impl.StateEvent;
    import robotlegs.bender.util.statemachine.impl.StateMachine;
    import robotlegs.bender.util.statemachine.impl.TransitionEvent;


    public class StateMachineTests {
        private static const STARTING:String = "state/starting";
        private static const START:String = "event/start";
        private static const START_ENTERING:String = "action/start/entering";
        private static const STARTED:String = "action/completed/start";
        private static const START_FAILED:String = "action/start/failed";
        private static const CONSTRUCTING:String = "state/constructing";
        private static const CONSTRUCT:String = "event/construct";
        private static const CONSTRUCT_ENTERING:String = "action/construct/entering";
        private static const CONSTRUCTED:String = "action/completed/construction";
        private static const CONSTRUCTION_EXIT:String = "event/construction/exit";
        private static const CONSTRUCTION_FAILED:String = "action/contruction/failed";
        private static const NAVIGATING:String = "state/navigating";
        private static const NAVIGATE:String = "event/navigate";

        ////////
        // State Machine Constants and Vars
        ///////
        private static const FAILING:String = "state/failing";
        private static const FAIL:String = "event/fail";
        private static const FSM_ONE_STATE:XML =
                <fsm initial={STARTING}>

                    <!-- THE INITIAL STATE -->
                    <state name={STARTING} entering={START_ENTERING}>

                    </state>
                </fsm>;
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

                        <transition action={CONSTRUCTED} target={NAVIGATING}/>
                        <transition action={CONSTRUCTION_FAILED} target={FAILING}/>
                    </state>

                    <!-- READY TO ACCEPT BROWSER OR USER NAVIGATION -->
                    <state name={NAVIGATING} complete={NAVIGATE}/>

                    <!-- REPORT FAILURE FROM ANY STATE -->
                    <state name={FAILING} complete={FAIL}/>

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
            Assert.assertEquals(STARTING, stateMachine.currentState.name);
        }

        [Test]
        public function advanceToNextState():void {
            var stateMachine:StateMachine = new StateMachine(eventDispatcher);
            fsmInjector.inject(stateMachine);

            eventDispatcher.dispatchEvent(new StateEvent(StateEvent.ACTION, STARTED));
            Assert.assertEquals(CONSTRUCTING, stateMachine.currentState.name);
        }

        [Test]
        public function constructionStateFailure():void {
            var stateMachine:StateMachine = new StateMachine(eventDispatcher);
            fsmInjector.inject(stateMachine);

            eventDispatcher.dispatchEvent(new StateEvent(StateEvent.ACTION, STARTED));
            Assert.assertEquals(CONSTRUCTING, stateMachine.currentState.name);

            eventDispatcher.dispatchEvent(new StateEvent(StateEvent.ACTION, CONSTRUCTION_FAILED));
            Assert.assertEquals(FAILING, stateMachine.currentState.name);
        }

        [Test]
        public function stateMachineComplete():void {
            var stateMachine:StateMachine = new StateMachine(eventDispatcher);
            fsmInjector.inject(stateMachine);

            eventDispatcher.dispatchEvent(new StateEvent(StateEvent.ACTION, STARTED));
            Assert.assertEquals(CONSTRUCTING, stateMachine.currentState.name);

            eventDispatcher.dispatchEvent(new StateEvent(StateEvent.ACTION, CONSTRUCTED));
            Assert.assertEquals(NAVIGATING, stateMachine.currentState.name);
        }

        [Test]
        public function cancelStateChange():void {
            var stateMachine:StateMachine = new StateMachine(eventDispatcher);
            fsmInjector.inject(stateMachine);

            eventDispatcher.dispatchEvent(new StateEvent(StateEvent.ACTION, STARTED));
            Assert.assertEquals(CONSTRUCTING, stateMachine.currentState.name);

            //listen for CONSTRUCTION_EXIT and block transition to next state
            eventDispatcher.addEventListener(CONSTRUCTION_EXIT,
                    function (event:StateEvent):void {
                        eventDispatcher.dispatchEvent(new TransitionEvent(TransitionEvent.CANCEL, stateMachine.currentState.name));
                    }
            );

            //attempt to complete construction
            eventDispatcher.dispatchEvent(new StateEvent(StateEvent.ACTION, CONSTRUCTED));
            Assert.assertEquals(CONSTRUCTING, stateMachine.currentState.name);
        }

        [Test]
        public function singleStateInConfigurationShouldBeAtThatStateInitially():void {
            var stateMachine:StateMachine = new StateMachine(eventDispatcher);
            fsmInjector = new FSMInjector(FSM_ONE_STATE);
            fsmInjector.inject(stateMachine);
            Assert.assertEquals("State should be starting", STARTING, stateMachine.currentState.name);
        }

        [Test]
        public function singleStateInConfigurationShouldStayInStateOnCompletionEvent():void {
            var stateMachine:StateMachine = new StateMachine(eventDispatcher);
            fsmInjector = new FSMInjector(FSM_ONE_STATE);
            fsmInjector.inject(stateMachine);

            eventDispatcher.dispatchEvent(new StateEvent(StateEvent.ACTION, STARTED));
            Assert.assertEquals("State should be starting", STARTING, stateMachine.currentState.name);
        }

        [Test(async)]
        public function stateTransitionPassesData():void {
            var stateMachine:StateMachine = new StateMachine(eventDispatcher);
            var data:Object = {value: "someData"};
            fsmInjector.inject(stateMachine);
            Async.handleEvent(this, eventDispatcher, StateEvent.ACTION, handleStateChange);
            eventDispatcher.dispatchEvent(new StateEvent(StateEvent.ACTION, STARTED, data));
        }

        private static function handleStateChange(event:StateEvent, pass:Object):void {
            Assert.assertTrue(event.data.value == "someData");
        }
    }
}