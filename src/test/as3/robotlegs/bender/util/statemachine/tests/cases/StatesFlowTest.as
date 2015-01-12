/**
 * Created by Dukobpa3 on 12.01.2015.
 */
package robotlegs.bender.util.statemachine.tests.cases {
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;
    import flash.events.TimerEvent;
    import flash.utils.Timer;

    import flexunit.framework.Assert;

    import mx.utils.StringUtil;

    import org.flexunit.async.Async;

    import robotlegs.bender.util.fsmInjector.impl.FSMInjector;
    import robotlegs.bender.util.statemachine.events.StateEvent;

    import robotlegs.bender.util.statemachine.impl.StateMachine;


    public class StatesFlowTest {

        private static const STATE_INIT:String = "state/init";
        private static const ACTION_READY:String = "action/ready";

        private static const STATE_READY:String = "state/ready";
        private static const STATE_READY_ENTERING:String = "event/ready_entering";
        private static const STATE_READY_EXITING:String = "event/ready_exiting";
        private static const STATE_READY_COMPLETE:String = "event/ready_complete";
        private static const ACTION_NEXT:String = "action/next";

        private static const STATE_NEXT:String = "state/next";
        private static const STATE_NEXT_ENTERING:String = "event/next_entering";
        private static const STATE_NEXT_EXITING:String = "event/next_exiting";
        private static const STATE_NEXT_COMPLETE:String = "event/next_complete";
        private static const STATE_NEXT_POP:String = "event/next_pop";


        private static const FSM:XML = <fsm initial={STATE_INIT}>
            <state name={STATE_INIT}>
                <transition action={ACTION_READY} target={STATE_READY}/>
            </state>

            <state name={STATE_READY} entering={STATE_READY_ENTERING} exiting={STATE_READY_EXITING} complete={STATE_READY_COMPLETE}>
                <transition action={ACTION_NEXT} target={STATE_NEXT}/>
            </state>

            <state name={STATE_NEXT} entering={STATE_NEXT_ENTERING} exiting={STATE_NEXT_EXITING} complete={STATE_NEXT_COMPLETE}>
                <pop action={STATE_NEXT_POP} />
            </state>

        </fsm>;

        private var eventDispatcher:IEventDispatcher;
        private var stateMachine:StateMachine;

        private var eventsArray:Array;


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
            Assert.assertEquals(STATE_INIT, stateMachine.state.name);
        }

        [Test (async, description="An async test through all flow")]
        public function flowTest():void {

            const matching:Array = [
                StringUtil.substitute("{0}:{1}", STATE_READY, StateEvent.STATE_START)
            ];

            eventDispatcher.addEventListener(StateEvent.STATE_START, onStateFlow);
            eventDispatcher.addEventListener(StateEvent.STATE_READY, onStateFlow);
            eventDispatcher.addEventListener(StateEvent.STATE_CANCEL, onStateFlow);
            eventDispatcher.addEventListener(StateEvent.STATE_POP, onStateFlow);

            eventDispatcher.addEventListener(STATE_READY_COMPLETE, onStateFlow);
            eventDispatcher.addEventListener(STATE_READY_ENTERING, onStateFlow);
            eventDispatcher.addEventListener(STATE_READY_EXITING, onStateFlow);

            eventDispatcher.addEventListener(STATE_NEXT_COMPLETE, onStateFlow);
            eventDispatcher.addEventListener(STATE_NEXT_ENTERING, onStateFlow);
            eventDispatcher.addEventListener(STATE_NEXT_EXITING, onStateFlow);


            eventDispatcher.dispatchEvent(new Event(ACTION_READY));
            eventDispatcher.dispatchEvent(new Event(ACTION_NEXT));
            eventDispatcher.dispatchEvent(new Event(ACTION_NEXT));
            eventDispatcher.dispatchEvent(new Event(STATE_NEXT_POP));

            var timer:Timer;
            timer = new Timer(3000);
            timer.addEventListener(
                    TimerEvent.TIMER,
                    Async.asyncHandler(
                            this,
                            handleTimerCheckCount,
                            3500, matching, handleTimeout ),
                    false, 0, true );
            timer.start();
            //Assert.assertEquals(STATE_INIT, stateMachine.state.name);
        }

        protected function handleTimerCheckCount( event:TimerEvent, data:Object):void {
            Assert.assertEquals(eventsArray, data);
        }

        protected function handleTimeout(data:Object):void {
            Assert.assertEquals(eventsArray, data);
        }

        private function onStateFlow(event:StateEvent):void {
            eventsArray ||= [];

            eventsArray.push(StringUtil.substitute("state is:{0} -> {1}:{2}", stateMachine.state.name, event.state.name, event.type));
        }
    }
}
