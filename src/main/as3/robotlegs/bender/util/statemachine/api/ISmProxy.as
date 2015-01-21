package robotlegs.bender.util.statemachine.api {

    /**
     * Proxy for sharing basic data of sm
     */
    public interface ISmProxy {
        /**
         * Current state
         */
        function get state():String

        /**
         * Pending state if started transition
         */
        function get pendingState():String

        /**
         * Is in transition
         */
        function get transition():Boolean;

        /**
         * Returns clone of history list
         */
        function get history():Vector.<String>;
    }
}
