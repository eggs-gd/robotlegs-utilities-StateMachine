package robotlegs.bender.util.statemachine.api {
    public interface IState {

        /**
         * The state name
         */
        function get name():String;

        /**
         * The notification to dispatch when entering the state
         */
        function get entering():String;

        /**
         * The notification to dispatch when exiting the state
         */
        function get exiting():String;

        /**
         * The notification to dispatch when the state has actually changed
         */
        function get changed():String;

        /**
         * Available transitions of this state.
         * returns clone of transitions list
         */
        function get transitions():Vector.<ITransition>;

        /**
         * Add a transition.
         * @param transition
         */
        function addTransition(transition:ITransition):Boolean;

        /**
         * Remove a previously defined transition.
         * @param actionName
         */
        function removeTransition(actionName:String):Boolean;

        /**
         * Get the target state name for a given action.
         * @param actionName
         */
        function getTransition(actionName:String):ITransition;
    }
}
