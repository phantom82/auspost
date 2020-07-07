/*
    Trigger for Case Standard Object.
    Handles the after Update event on Case.
*/
trigger caseTriggers on Case (before insert, before update, after insert, after update) {
    if(trigger.isAfter && trigger.isUpdate) {
        caseTriggerHandler.handleCaseAfterUpdate(trigger.oldMap, trigger.newMap);
    }
}