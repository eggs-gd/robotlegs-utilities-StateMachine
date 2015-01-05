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
         * Define a transition.
         *
         * @param action the name of the StateMachine.ACTION event type.
         * @param target the name of the target state to transition to.
         */
        function defineTransition(action:String, target:String):void ;

        /**
         * Remove a previously defined transition.
         */
        function removeTransition(action:String):void;

        /**
         * Get the target state name for a given action.
         */
        function getTarget(action:String):String;
    }
}
