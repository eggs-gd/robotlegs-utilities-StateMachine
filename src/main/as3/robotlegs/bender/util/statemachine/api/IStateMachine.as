package robotlegs.bender.util.statemachine.api {
    /**
     * @author Benoit vinay - ben@benoitvinay.com
     */
    public interface IStateMachine {

        function get previousState():IState
        function get currentState():IState
        function get pendingState():IState

        function get history():Vector.<String>;

        function onRegister():void;
        function onRemove():void;

        /**
         * Registers the entry and exit commands for a given state.
         *
         * @param state the state to which to register the above commands
         * @param initial boolean telling if this is the initial state of the system
         */
        function registerState(state:IState, initial:Boolean = false):Boolean;

        /**
         * Remove a state mapping.
         * <P>Removes the entry and exit commands for a given state as well as the state mapping itself.</P>
         *
         * @param stateName
         */
        function removeState(stateName:String):Boolean;

        /**
         * Retrieve a state.
         * <P>Utility method for retrieving a State.</P>
         *
         * @param stateName
         */
        function getStateByName(stateName:String):IState;

        /**
         * Retrieve a state.
         * <P>Utility method for retrieving a State.</P>
         *
         * @param action
         */
        function getStateByAction(action:String):IState;

        function dispose():void;
    }
}