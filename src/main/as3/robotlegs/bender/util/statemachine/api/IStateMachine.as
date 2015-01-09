package robotlegs.bender.util.statemachine.api {

    public interface IStateMachine {

        /**
         * Current state
         */
        function get state():IState

        /**
         * Pending state if started transition
         */
        function get pendingState():IState

        /**
         * Currently running transition
         */
        function get transition():ITransition;

        /**
         * Returns clone of history list
         */
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
         * Completely destroy current SM
         */
        function dispose():void;
    }
}