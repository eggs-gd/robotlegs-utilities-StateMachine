package robotlegs.bender.util.statemachine.api {
    import robotlegs.bender.util.statemachine.impl.State;


    /**
     * @author Benoit vinay - ben@benoitvinay.com
     */
    public interface IStateMachine {

        function get previousState():State

        function get currentState():State

        function get currentStateName():String;

        function get history():Array;


        function onRegister():void;

        function onRemove():void;

        function registerState(state:State, initial:Boolean = false):void;

        function getStateByName(stateName:String):State;

        function getStateForAction(action:String):State;

        function removeState(stateName:String):void;

        function getHistory(offset:int):String;

        function dispose():void;
    }
}