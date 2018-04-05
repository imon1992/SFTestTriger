trigger EmployeeSkillsTrigger on Employee_Skills__c (before insert, before update, 
                                        before delete, after insert, after update, 
                                        after delete, after undelete) {
    EmployeeSkillsTriggerHandler.handleTrigger();
}