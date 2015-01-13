/**
 * Created by Dukobpa3 on 12.01.2015.
 */
package robotlegs.bender.util.statemachine {
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;
    import flash.events.TimerEvent;
    import flash.utils.Timer;

    import flexunit.framework.Assert;

    import mx.utils.StringUtil;

    import org.flexunit.async.Async;
    import org.hamcrest.assertThat;
    import org.hamcrest.collection.array;

    import robotlegs.bender.util.fsmInjector.impl.FSMInjector;
    import robotlegs.bender.util.statemachine.events.StateEvent;

    import robotlegs.bender.util.statemachine.impl.StateMachine;


    public class StatesFlowTest {

        private static const STATE_ZERO:String = "state/init";
        private static const ACTION_FIRST:String = "action/ready";

        private static const STATE_FIRST:String = "state/ready";
        private static const STATE_FIRST_ENTERING:String = "event/ready_entering";
        private static const STATE_FIRST_EXITING:String = "event/ready_exiting";
        private static const STATE_FIRST_COMPLETE:String = "event/ready_complete";
        private static const ACTION_SECOND:String = "action/next";

        private static const STATE_SECOND:String = "state/next";
        private static const STATE_SECOND_ENTERING:String = "event/next_entering";
        private static const STATE_SECOND_EXITING:String = "event/next_exiting";
        private static const STATE_SECOND_COMPLETE:String = "event/next_complete";
        private static const STATE_SECOND_POP:String = "event/next_pop";


        private static const FSM:XML = <fsm initial={STATE_ZERO}>
            <state name={STATE_ZERO}>
                <transition action={ACTION_FIRST} target={STATE_FIRST}/>
            </state>

            <state name={STATE_FIRST} entering={STATE_FIRST_ENTERING} exiting={STATE_FIRST_EXITING} complete={STATE_FIRST_COMPLETE}>
                <transition action={ACTION_SECOND} target={STATE_SECOND}/>
            </state>

            <state name={STATE_SECOND} entering={STATE_SECOND_ENTERING} exiting={STATE_SECOND_EXITING} complete={STATE_SECOND_COMPLETE}>
                <pop action={STATE_SECOND_POP} />
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
            Assert.assertEquals(STATE_ZERO, stateMachine.state.name);
        }

        [Test (async, description="An async test through all flow")]
        public function flowTest():void {

            const matching:Array = [
                StringUtil.substitute("state is:{0} -> {1}:{2}", STATE_ZERO, STATE_FIRST, STATE_FIRST_ENTERING),
                StringUtil.substitute("state is:{0} -> {1}:{2}", STATE_ZERO, STATE_FIRST, StateEvent.STATE_START),
                StringUtil.substitute("state is:{0} -> {1}:{2}", STATE_FIRST, STATE_FIRST, StateEvent.STATE_READY),
                StringUtil.substitute("state is:{0} -> {1}:{2}", STATE_FIRST, STATE_FIRST, STATE_FIRST_COMPLETE),

                StringUtil.substitute("state is:{0} -> {1}:{2}", STATE_FIRST, STATE_SECOND, STATE_SECOND_ENTERING),
                StringUtil.substitute("state is:{0} -> {1}:{2}", STATE_FIRST, STATE_SECOND, StateEvent.STATE_START),
                StringUtil.substitute("state is:{0} -> {1}:{2}", STATE_SECOND, STATE_SECOND, StateEvent.STATE_READY),
                StringUtil.substitute("state is:{0} -> {1}:{2}", STATE_SECOND, STATE_SECOND, STATE_SECOND_COMPLETE),

                StringUtil.substitute("state is:{0} -> {1}:{2}", STATE_SECOND, STATE_SECOND, StateEvent.STATE_POP),
                StringUtil.substitute("state is:{0} -> {1}:{2}", STATE_SECOND, STATE_SECOND, STATE_SECOND_EXITING),
                StringUtil.substitute("state is:{0} -> {1}:{2}", STATE_FIRST, STATE_FIRST, StateEvent.STATE_READY)
            ];

            eventDispatcher.addEventListener(StateEvent.STATE_START, onStateFlow);
            eventDispatcher.addEventListener(StateEvent.STATE_READY, onStateFlow);
            eventDispatcher.addEventListener(StateEvent.STATE_CANCEL, onStateFlow);
            eventDispatcher.addEventListener(StateEvent.STATE_POP, onStateFlow);

            eventDispatcher.addEventListener(STATE_FIRST_COMPLETE, onStateFlow);
            eventDispatcher.addEventListener(STATE_FIRST_ENTERING, onStateFlow);
            eventDispatcher.addEventListener(STATE_FIRST_EXITING, onStateFlow);

            eventDispatcher.addEventListener(STATE_SECOND_COMPLETE, onStateFlow);
            eventDispatcher.addEventListener(STATE_SECOND_ENTERING, onStateFlow);
            eventDispatcher.addEventListener(STATE_SECOND_EXITING, onStateFlow);


            eventDispatcher.dispatchEvent(new Event(ACTION_FIRST));
            eventDispatcher.dispatchEvent(new Event(ACTION_SECOND));
            eventDispatcher.dispatchEvent(new Event(ACTION_SECOND));
            eventDispatcher.dispatchEvent(new Event(STATE_SECOND_POP));

            var handler:Function = Async.asyncHandler(this, handleTimerCheckCount, 3500, matching, handleTimeout);
            var timer:Timer;
            timer = new Timer(3000, 1);
            timer.addEventListener(TimerEvent.TIMER, handler, false, 0, true );
            timer.start();
        }

        protected function handleTimerCheckCount( event:TimerEvent, data:Object):void {
            assertThat(eventsArray, array(data));
            //Assert.assertEquals(eventsArray, data);
        }

        protected function handleTimeout(data:Object):void {
            Assert.assertTrue(false);
        }

        private function onStateFlow(event:StateEvent):void {
            eventsArray ||= [];

            eventsArray.push(StringUtil.substitute("state is:{0} -> {1}:{2}", stateMachine.state.name, event.state.name, event.type));
        }
    }
}
