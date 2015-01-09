/*
 ADAPTED FOR ROBOTLEGS FROM:
 PureMVC AS3 Utility - StateMachine
 Copyright (c) 2008 Neil Manuell, Cliff Hall
 Your reuse is governed by the Creative Commons Attribution 3.0 License
 */
package robotlegs.bender.util.fsmInjector.impl {
    import robotlegs.bender.util.fsmInjector.api.IFSMInjector;
    import robotlegs.bender.util.statemachine.api.IState;
    import robotlegs.bender.util.statemachine.api.IStateMachine;
    import robotlegs.bender.util.statemachine.api.ITransition;
    import robotlegs.bender.util.statemachine.impl.State;
    import robotlegs.bender.util.statemachine.impl.Transition;


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
        private static function stateFromXml(xmlState:XML):IState {
            // Create State object
            var name:String = xmlState.@name.toString();
            var exiting:String = xmlState.@exiting.toString();
            var entering:String = xmlState.@entering.toString();
            var complete:String = xmlState.@complete.toString();

            var state:IState = new State(name, entering, exiting, complete);

            // Create transitions
            var transitions:XMLList = xmlState..transition as XMLList;
            for (var i:int = 0; i < transitions.length(); i++) {
                var xmlTransition:XML = transitions[i];
                var transition:ITransition = new Transition(
                        String(xmlTransition.@action),
                        String(xmlTransition.@cancel),
                        String(xmlTransition.@target),
                        String(xmlTransition.@complete)
                );
                state.addTransition(transition);
            }

            // Create popActions
            var popActions:XMLList = xmlState..pop as XMLList;
            for (i = 0; i < popActions.length(); i++) {
                var xmlPopAction:XML = popActions[i];
                var popAction:String = String(xmlPopAction.@action);
                state.addPopAction(popAction);
            }

            return state;
        }

        //=====================================================================
        //  parameters
        //=====================================================================

        public function FSMInjector(fsm:XML) {
            this.fsm = fsm;
        }
        protected var _initialState:String;
        protected var _stateList:Array;

        protected var _fsm:XML;

        // The List of State objects

        public function get fsm():XML { return _fsm; }

        public function set fsm(value:XML):void {
            dispose();
            _fsm = value;
            _initialState = XML(_fsm.@initial).toString();
        }

        //=====================================================================
        //  constructor
        //=====================================================================

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


        //=====================================================================
        //  public
        //=====================================================================

        public function inject(stateMachine:IStateMachine):void {
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