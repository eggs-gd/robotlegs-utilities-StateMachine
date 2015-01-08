package robotlegs.bender.util.statemachine.api {

    public interface ITransition {
        /**
         * Notification which init start this transition
         */
        function get action():String;

        /**
         * Target state of this transition
         */
        function get target():String;

        /**
         * Notification which dispatched when transition complete
         * When empty - than transition is instant
         */
        function get complete():String;
    }
}
