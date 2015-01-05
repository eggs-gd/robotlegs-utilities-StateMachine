package robotlegs.bender.util.fsmInjector.api {
    import robotlegs.bender.util.statemachine.impl.StateMachine;


    /**
     * @author Benoit vinay - ben@benoitvinay.com
     */
    public interface IFSMInjector {
        function inject(stateMachine:StateMachine):void;

        function set xml(value:XML):void;

        function get xml():XML;

        function dispose():void;
    }
}