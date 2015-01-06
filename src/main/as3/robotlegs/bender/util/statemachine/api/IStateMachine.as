package robotlegs.bender.util.statemachine.api {
    /**
     * @author Benoit vinay - ben@benoitvinay.com
     */
    public interface IStateMachine {

        function get previousState():IState

        function get currentState():IState

        function get currentStateName():String;

        function get history():Vector.<String>;


        function onRegister():void;

        function onRemove():void;

        function registerState(state:IState, initial:Boolean = false):void;

        function getStateByName(stateName:String):IState;

        function getStateForAction(action:String):IState;

        function removeState(stateName:String):void;

        function getHistory(offset:int):String;

        function dispose():void;
    }
}