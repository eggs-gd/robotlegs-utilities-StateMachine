/*
 ADAPTED FOR ROBOTLEGS FROM:
 PureMVC AS3 Utility - StateMachine
 Copyright (c) 2008 Neil Manuell, Cliff Hall
 Your reuse is governed by the Creative Commons Attribution 3.0 License
 */
package robotlegs.bender.util.fsmInjector.impl {
    import robotlegs.bender.util.statemachine.impl.*;
    import flash.events.IEventDispatcher;

    import robotlegs.bender.util.fsmInjector.api.IFSMInjector;


    public class FSMInjector implements IFSMInjector {

        //=====================================================================
        //  Static
        //=====================================================================
        /**
         * Fill states list from given XML mapping
         * @param fsm xmlMap
         * @return Array of states
         */
        private static function fillStatesList(fsm:XML):Array {
            var result:Array = [];

            var xmlStates:XMLList = fsm..state;
            for (var i:int = 0; i < xmlStates.length(); i++) {
                var xmlState:XML = xmlStates[i];
                result.push(stateFromXml(xmlState));
            }
            return result;
        }

        /**
         * Creates a <code>State</code> instance from its XML definition.
         */
        private static function stateFromXml(xmlState:XML):State {
            // Create State object
            var name:String = xmlState.@name.toString();
            var exiting:String = xmlState.@exiting.toString();
            var entering:String = xmlState.@entering.toString();
            var changed:String = xmlState.@changed.toString();

            var state:State = new State(name, entering, exiting, changed);

            // Create transitions
            var transitions:XMLList = xmlState..transition as XMLList;
            for (var i:int = 0; i < transitions.length(); i++) {
                var xmlTransition:XML = transitions[i];
                state.defineTransition(String(xmlTransition.@action), String(xmlTransition.@target));
            }
            return state;
        }


        //=====================================================================
        //  parameters
        //=====================================================================
        protected var _initialState:String;

        protected var _fsm:XML;
        public function get fsm():XML { return _fsm; }
        public function set fsm(value:XML):void {
            dispose();
            _fsm = value;
            _initialState = XML(_fsm.@initial).toString();
        }

        // The List of State objects
        protected var _stateList:Array;
        /**
         * Get the state definitions.
         * <P>
         * Creates and returns the array of State objects
         * from the FSM on first call, subsequently returns
         * the existing array.</P>
         */
        protected function get states():Array {
            _stateList ||= fillStatesList(_fsm);
            return _stateList;
        }

        [Inject] /** @private */
        public var eventDispatcher:IEventDispatcher;

        //=====================================================================
        //  constructor
        //=====================================================================
        public function FSMInjector(fsm:XML) {
            this.fsm = fsm;
        }


        //=====================================================================
        //  public
        //=====================================================================
        public function inject(stateMachine:StateMachine):void {
            // Register all the states with the StateMachine
            for each (var state:State in states) {
                stateMachine.registerState(state, (state.name == _initialState));
            }

            // Register the StateMachine with the facade
            stateMachine.onRegister();
        }

        public function dispose():void {
            _fsm = null;
            _stateList = null;
        }
    }
}