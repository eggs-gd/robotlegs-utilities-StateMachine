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
        function get complete():String;

        /**
         * Available transitions of this state.
         * returns clone of transitions list
         */
        function get transitions():Vector.<ITransition>;

        /**
         * List of event names for pop back in state history
         */
        function get popActions():Vector.<String>;

        /**
         * Add action for pop up state
         * @param action
         * @return true if added
         */
        function addPopAction(action:String):Boolean;

        /**
         * checks if state can start transition
         * @param action
         * @return
         */
        function hasTransition(action:String):Boolean;

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
         * Get the transition for a given action.
         * @param actionName
         */
        function getTransition(actionName:String):ITransition;

        /**
         * Get the target state name for a given action.
         * @param actionName
         * @return stateName
         */
        function getNextState(actionName:String):String;
    }
}
