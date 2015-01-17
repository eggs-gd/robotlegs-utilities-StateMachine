package robotlegs.bender.util.statemachine.api {

    public interface ITransition {
        /**
         * Event which init start this transition
         */
        function get action():String;

        /**
         * Event which init cancelling this transition
         */
        function get cancel():String;

        /**
         * Target state of this transition
         */
        function get target():String;

        /**
         * Notification which dispatched when transition complete
         * When empty - than transition is instant
         */
        function get complete():String;

        /**
         * This is not continuous transition
         */
        function get isInstant():Boolean;
    }
}
