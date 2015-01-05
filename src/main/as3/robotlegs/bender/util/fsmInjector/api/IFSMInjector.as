package robotlegs.bender.util.fsmInjector.api {
    import robotlegs.bender.util.statemachine.impl.StateMachine;


    /**
     * @author Benoit vinay - ben@benoitvinay.com
     */
    public interface IFSMInjector {

        /**
         * XML
         * allow to completely change the FSM
         */
        function set fsm(value:XML):void;
        function get fsm():XML;

        /**
         * Inject the <code>StateMachine</code> into the Robotlegs apparatus.
         * <P>
         * Creates the <code>StateMachine</code> instance, registers all the states
         */
        function inject(stateMachine:StateMachine):void;

        /**
         * dispose
         */
        function dispose():void;
    }
}